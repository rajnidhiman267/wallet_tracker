import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<void> login({required String email, required String password});
  Future<UserCredential> signUp({required String email, required String password});
  Future<void> updateProfile({required String name, String? photoUrl});
  Future<void> signInWithGoogleCall();
  Future<void> signOut();

  // Biometric
  // isBiometricRegistered = hardware available AND user has previously logged in
  Future<bool> isBiometricRegistered();
  Future<bool> authenticateWithBiometric();
}
