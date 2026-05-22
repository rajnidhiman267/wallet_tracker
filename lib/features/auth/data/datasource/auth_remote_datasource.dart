import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tracker_app/features/auth/data/model/local_auth_model.dart';

class AuthRemoteDatasource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn _googleSignIn;
  StreamSubscription? _googleAuthSubscription;
  AuthRemoteDatasource({
    required this.firebaseAuth,
    required this.firestore,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance {
    // Initialize the stream right when the data source is created
    _initGoogleSignInBackgroundStreams();
  }

  /// Sets up modern stream-based event tracking for background lifecycle events/// Sets up modern stream-based event tracking for background lifecycle events
  void _initGoogleSignInBackgroundStreams() {
    unawaited(
      _googleSignIn
          .initialize(
            // Add your Firebase Web Client ID here to fix the reauth error [16]
            serverClientId:
                'YOUR_FIREBASE_WEB_CLIENT_ID.apps.googleusercontent.com',
          )
          .then((_) {
            // Listen to the live authentication streams
            _googleAuthSubscription = _googleSignIn.authenticationEvents.listen(
              _handleGoogleAuthenticationEvent,
              onError: _handleGoogleAuthenticationError,
            );

            // Instantly verify if a cached login token can sign the user in silently
            _googleSignIn.attemptLightweightAuthentication();
          }),
    );
  }

  /// Handles lightweight authentication background streams
  void _handleGoogleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      try {
        // Fetch general identity details (with required await!)
        final GoogleSignInAuthentication googleAuth = event.user.authentication;

        // Fetch the client authorization access token explicitly
        final List<String> scopes = ['email', 'profile'];
        final clientAuth = await event.user.authorizationClient.authorizeScopes(
          scopes,
        );

        // Generate credentials cleanly for Firebase mapping
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: clientAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Update the current user instance on Firebase Auth
        final UserCredential userCredential = await firebaseAuth
            .signInWithCredential(credential);

        if (userCredential.user != null) {
          await _syncUserToFirestoreIfNeeded(userCredential.user!);
        }
      } catch (e) {
        _handleGoogleAuthenticationError(e);
      }
    }
  }

  void _handleGoogleAuthenticationError(Object error) {
    print("Google Background Auth Error: $error");
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    final response = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> login({required String email, required String password}) async {
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> updateProfile({required String name, String? photoUrl}) async {
    final user = firebaseAuth.currentUser;

    await user?.updateDisplayName(name);

    if (photoUrl != null) {
      await user?.updatePhotoURL(photoUrl);
    }

    final userModel = LocalUserModel(
      uid: user?.uid ?? '',
      email: user?.email ?? '',
      name: name,
      photoUrl: photoUrl,
      updatedAt: DateTime.now(),
    );

    await firestore
        .collection('users')
        .doc(user?.uid)
        .set(userModel.toJson(), SetOptions(merge: true));
  }

  /// Directly triggers the interactive Google Sign-In sequence/// Directly triggers the interactive Google Sign-In sequence (Tied to your UI button)
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final List<String> scopes = ['email', 'profile'];
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(
        scopes,
      );

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: clientAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception("Firebase User is null");
      }

      await _syncUserToFirestoreIfNeeded(firebaseUser);
    } catch (e) {
      throw Exception("Google Sign-In Failed: $e");
    }
  }

  /// Private helper method to handle Firestore updates avoiding code duplication
  Future<void> _syncUserToFirestoreIfNeeded(User firebaseUser) async {
    final userDoc = await firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!userDoc.exists) {
      await firestore.collection('users').doc(firebaseUser.uid).set({
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'displayName': firebaseUser.displayName,
        'photoUrl': firebaseUser.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Call this when destroying the data source to prevent memory leaks
  void dispose() {
    _googleAuthSubscription?.cancel();
  }
}
