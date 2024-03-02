import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String name;
  final String email;
  final String profilePicture;

  UserProfile({
    required this.name,
    required this.email,
    required this.profilePicture,
  });

  factory UserProfile.fromSnapshot(DocumentSnapshot snapshot) {
    return UserProfile(
      name: snapshot['name'] ?? '',
      email: snapshot['email'] ?? '',
      profilePicture: snapshot['profilePicture'] ?? '',
    );
  }

  static Future<UserProfile?> getUserProfile(String? uid) async {
    if (uid == null) return null;

    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return UserProfile.fromSnapshot(snapshot);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
}
