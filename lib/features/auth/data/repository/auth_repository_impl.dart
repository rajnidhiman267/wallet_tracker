import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:tracker_app/features/auth/data/model/local_auth_model.dart' show LocalUserModel;
import 'package:tracker_app/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource authRemoteDataSource;
  AuthRepositoryImpl({required this.authRemoteDataSource});
  @override
  Future<void> login({required String email, required String password}) async {
    await authRemoteDataSource.login(email: email, password: password);
  }

  @override
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await authRemoteDataSource.signUp(email: email, password: password);
  }

  @override
  Future<void> updateProfile({required String name, String? photoUrl}) async {
    await authRemoteDataSource.updateProfile(name: name, photoUrl: photoUrl);
  }

  @override
  Future<void> signInWithGoogleCall() async {
    return authRemoteDataSource.signInWithGoogle();
  }
}
