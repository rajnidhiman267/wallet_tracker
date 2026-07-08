import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:tracker_app/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<void> login({required String email, required String password}) =>
      authRemoteDataSource.login(email: email, password: password);

  @override
  Future<UserCredential> signUp(
          {required String email, required String password}) =>
      authRemoteDataSource.signUp(email: email, password: password);

  @override
  Future<void> updateProfile({required String name, String? photoUrl}) =>
      authRemoteDataSource.updateProfile(name: name, photoUrl: photoUrl);

  @override
  Future<void> signInWithGoogleCall() => authRemoteDataSource.signInWithGoogle();

  @override
  Future<void> signOut() => authRemoteDataSource.signOut();

  @override
  Future<bool> isBiometricRegistered() =>
      authRemoteDataSource.isBiometricRegistered();

  @override
  Future<bool> authenticateWithBiometric() =>
      authRemoteDataSource.authenticateWithBiometric();
}
