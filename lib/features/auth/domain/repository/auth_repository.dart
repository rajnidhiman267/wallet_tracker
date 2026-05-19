import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<UserCredential> signUp({required String email, required String password});
  Future<void> login({
    required String email,
    required String password,
  });
  Future<void> updateProfile({
  required String name,
  String? photoUrl,
});
}
