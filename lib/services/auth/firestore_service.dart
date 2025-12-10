import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twinkle/models/users_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user with FirebaseAuth uid
  Future<void> createUser(String uid, UsersModel user) async {
    try {
      await _firestore.collection('users').doc(uid).set(user.toMap());
    } catch (e) {
      throw Exception("Failed to create user: $e");
    }
  }

  // Get user by uid
  Future<UsersModel> getUser(String uid) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return UsersModel.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception("User not found");
      }
    } catch (e) {
      throw Exception("Failed to get user: $e");
    }
  }

  // Update online status
  Future<void> updateUserOnlineStatus(String uid, bool is_online) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        await _firestore.collection('users').doc(uid).update({
          'is_online': is_online,
          'last_seen': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      throw Exception("Failed to update user online status: $e");
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception("Failed to delete user: $e");
    }
  }
}
