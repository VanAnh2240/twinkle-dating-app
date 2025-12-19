// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:twinkle/models/profile_model.dart';
// import 'package:twinkle/models/users_model.dart';

// class ProfileSetupService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   /// ---------- PROFILE ----------
//   Future<void> createProfile(String userId, ProfileModel profile) async {
//     await _firestore
//         .collection('Profiles')
//         .doc(userId)
//         .set(profile.toMap());
//   }

//   Future<void> updateProfileFields(
//       String userId, Map<String, dynamic> fields) async {
//     await _firestore
//         .collection('Profiles')
//         .doc(userId)
//         .set(fields, SetOptions(merge: true));
//   }

//   Future<bool> profileExists(String userId) async {
//     final doc =
//         await _firestore.collection('Profiles').doc(userId).get();
//     return doc.exists;
//   }

//   Future<ProfileModel?> getProfile(String userId) async {
//     final doc =
//         await _firestore.collection('Profiles').doc(userId).get();
//     if (!doc.exists) return null;
//     return ProfileModel.fromMap(doc.data()!);
//   }

//   /// ---------- USER ----------
//   Future<void> updateUser(
//       String userId, Map<String, dynamic> fields) async {
//     await _firestore
//         .collection('Users')
//         .doc(userId)
//         .update(fields);
//   }

//   Future<UsersModel?> getUser(String userId) async {
//     final doc =
//         await _firestore.collection('Users').doc(userId).get();
//     if (!doc.exists) return null;
//     return UsersModel.fromMap(doc.data()!);
//   }
// }
