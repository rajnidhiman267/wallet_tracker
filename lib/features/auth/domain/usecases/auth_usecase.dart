import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_app/features/auth/data/model/local_auth_model.dart' show LocalUserModel;
import 'package:tracker_app/features/auth/domain/repository/auth_repository.dart';

class AuthUseCase {
  final AuthRepository authRepository;

  AuthUseCase({required this.authRepository});

  Future<UserCredential> signUpCall({
    required String email,
    required String password,
  }) async {
    return await authRepository.signUp(email: email, password: password);
  }

  Future<void> loginCall({
    required String email,
    required String password,
  }) async {
    await authRepository.login(email: email, password: password);
  }

  Future<void> updateProfileCall({
    required String name,
    String? photoUrl,
  }) async {
    await authRepository.updateProfile(name: name, photoUrl: photoUrl);
  }

  Future<void> signInWithGoogleCall() async {
    return await authRepository.signInWithGoogleCall();
  }
}
