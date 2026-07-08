import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker_app/features/auth/data/model/local_auth_model.dart';

// ─── KEY STORED IN SharedPreferences ────────────────────────────────────────
// After a successful email/password login we write this flag so the biometric
// button knows there IS a saved Firebase session to unlock.
const _kBiometricEnabledKey = 'biometric_enabled';

class AuthRemoteDatasource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // ── GoogleSignIn is initialised lazily so it never races the UI ──────────
  GoogleSignIn? _googleSignIn;

  AuthRemoteDatasource({required this.firebaseAuth, required this.firestore});

  // ═══════════════════════════════════════════════════════════════════════════
  // BIOMETRIC
  //
  // HOW BIOMETRIC "REGISTRATION" WORKS IN THIS APP
  // ───────────────────────────────────────────────
  // local_auth has NO concept of users or accounts — it only asks the OS
  // "is this person who owns the device?".  Firebase Auth, on the other hand,
  // keeps its session in a persistent token store (it survives app restarts).
  //
  // So the flow is:
  //   1. User signs in with email + password (or Google) → Firebase session saved.
  //   2. We call `registerBiometric()` which writes a flag to SharedPreferences.
  //   3. On the next app open, `isBiometricRegistered()` returns true, so the
  //      "Use Biometrics" button is shown on the login screen.
  //   4. User taps it → `authenticateWithBiometric()` shows the OS prompt.
  //   5. If the OS says ✓, Firebase session is still alive → navigate to home.
  //   6. If the user signs out we call `unregisterBiometric()` to clear the flag.
  // ═══════════════════════════════════════════════════════════════════════════

  /// Call this right after a successful email/password or Google sign-in.
  Future<void> registerBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricEnabledKey, true);
  }

  /// Call on sign-out so the biometric button hides until next login.
  Future<void> unregisterBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBiometricEnabledKey);
  }

  /// True when the user has previously logged in on this device AND the device
  /// supports biometrics.
  Future<bool> isBiometricRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    final flag = prefs.getBool(_kBiometricEnabledKey) ?? false;
    if (!flag) return false;
    // Also confirm the hardware is still available
    return _checkHardwareAvailable();
  }

  Future<bool> _checkHardwareAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      return canCheck && supported;
    } on PlatformException catch (e) {
      debugPrint('Biometric hardware check error: $e');
      return false;
    }
  }

  /// Trigger the OS biometric / PIN prompt.
  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Verify your identity to open Expense Tracker',

        biometricOnly: false, // allow PIN/pattern as fallback
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric authenticate error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMAIL / PASSWORD
  // ═══════════════════════════════════════════════════════════════════════════

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // No biometric registration here — user hasn't "logged in" yet.
    // They will log in for the first time via the login screen.
    return credential;
  }

  Future<void> login({required String email, required String password}) async {
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // ✅ Register biometric after successful login so the button appears next time
    await registerBiometric();
  }

  Future<void> signOut() async {
    await unregisterBiometric();
    await firebaseAuth.signOut();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> updateProfile({required String name, String? photoUrl}) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await user.updateDisplayName(name);
    if (photoUrl != null && photoUrl.isNotEmpty) {
      await user.updatePhotoURL(photoUrl);
    }

    final model = LocalUserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: name,
      photoUrl: photoUrl,
      updatedAt: DateTime.now(),
    );

    await firestore
        .collection('users')
        .doc(user.uid)
        .set(model.toJson(), SetOptions(merge: true));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GOOGLE SIGN-IN
  //
  // FIX: The old code used GoogleSignIn.instance (singleton) + background
  // stream callbacks.  The problem is that _initGoogleSignInBackgroundStreams()
  // is async-fire-and-forget.  When the user taps "Sign in with Google" the
  // GoogleSignIn might not be initialised yet → race condition → silent crash.
  //
  // Fix: initialise GoogleSignIn lazily, AWAIT it, then call authenticate().
  // The background stream is kept for silent re-auth on app open, but the
  // button tap path is fully self-contained and does NOT depend on it.
  // ═══════════════════════════════════════════════════════════════════════════

  /// Replace YOUR_WEB_CLIENT_ID with the OAuth 2.0 Web client ID from your
  /// Firebase project → Authentication → Sign-in method → Google → Web SDK config.
  /// It looks like:  XXXXXXXXXX-xxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
  static const _webClientId =
      'YOUR_WEB_CLIENT_ID_FROM_FIREBASE_CONSOLE.apps.googleusercontent.com';

  Future<GoogleSignIn> _getGoogleSignIn() async {
    if (_googleSignIn != null) return _googleSignIn!;
    final instance = GoogleSignIn.instance;
    await instance.initialize(serverClientId: _webClientId);
    _googleSignIn = instance;
    return instance;
  }

  Future<void> signInWithGoogle() async {
    try {
      final gsi = await _getGoogleSignIn();

      // This opens the native Google account picker
      final GoogleSignInAccount googleUser = await gsi.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) throw Exception('Firebase user is null');

      await _syncUserToFirestoreIfNeeded(firebaseUser);

      // ✅ Register biometric after successful Google login too
      await registerBiometric();
    } catch (e) {
      // Unwrap the double-Exception wrapping so callers get readable messages
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<void> _syncUserToFirestoreIfNeeded(User user) async {
    final doc = await firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
