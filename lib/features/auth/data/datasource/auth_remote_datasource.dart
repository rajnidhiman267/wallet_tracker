import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_app/features/auth/data/model/local_auth_model.dart';

class AuthRemoteDatasource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  AuthRemoteDatasource({required this.firebaseAuth, required this.firestore});

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
}
