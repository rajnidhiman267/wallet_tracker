import 'package:cloud_firestore/cloud_firestore.dart';

class LocalUserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime? updatedAt;

  LocalUserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.updatedAt,
  });

  factory LocalUserModel.fromJson(Map<String, dynamic> json) {
    return LocalUserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'updatedAt': updatedAt,
    };
  }
}
