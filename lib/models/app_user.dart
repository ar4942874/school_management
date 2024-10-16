import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String role;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.role,
  });

  // Factory constructor to create an AppUser from Firebase User and additional data
  factory AppUser.fromFirebase(User user, String role) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL,
      role: role,
    );
  }

  // Factory method to create AppUser from Firestore document
 factory AppUser.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: data['id'] ?? '',
      displayName: data['name'] ?? '',
      email: data['email'] ?? '',
      role: 'staff' ,
      photoURL: '',
    );
  }
}
