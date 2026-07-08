import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_app/features/auth/domain/repository/auth_repository.dart';

class AuthUseCase {
  final AuthRepository authRepository;

  AuthUseCase({required this.authRepository});

  Future<UserCredential> signUpCall(
          {required String email, required String password}) =>
      authRepository.signUp(email: email, password: password);

  Future<void> loginCall({required String email, required String password}) =>
      authRepository.login(email: email, password: password);

  Future<void> updateProfileCall({required String name, String? photoUrl}) =>
      authRepository.updateProfile(name: name, photoUrl: photoUrl);

  Future<void> signInWithGoogleCall() => authRepository.signInWithGoogleCall();

  Future<void> signOut() => authRepository.signOut();

  /// True only when: device has biometric hardware AND user has a saved session.
  Future<bool> isBiometricRegistered() => authRepository.isBiometricRegistered();

  Future<bool> authenticateWithBiometric() =>
      authRepository.authenticateWithBiometric();
}
