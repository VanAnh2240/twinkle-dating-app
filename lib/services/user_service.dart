import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twinkle/models/users_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user FirebaseAuth
  Future<void> createUser(String uid, UsersModel user) async {
    try {
      await _firestore.collection('Users').doc(uid).set(user.toMap());
    } catch (e) {
      throw Exception("Failed to create user: $e");
    }
  }

  // Get user by uid
  Future<UsersModel> getUserById(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get();

    if (!doc.exists) {
      throw Exception("User not found");
    }

    return UsersModel.fromMap(doc.data()!..['user_id'] = doc.id);
  }


  // Update online status
  Future<void> updateUserOnlineStatus(String uid, bool is_online) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('Users').doc(uid).get();
      if (doc.exists) {
        await _firestore.collection('Users').doc(uid).update({
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
      await _firestore.collection('Users').doc(uid).delete();
    } catch (e) {
      throw Exception("Failed to delete user: $e");
    }
  }


  //random user
  Future<List<UsersModel>> getRandomUsers(String currentUserId) async {
    try {
      // 1. Lấy danh sách user đã like/dislike để bỏ qua
      final actionsSnapshot = await _firestore
          .collection("swipes")
          .doc(currentUserId)
          .get();

      List<String> excludedIds = [];

      if (actionsSnapshot.exists) {
        excludedIds = List<String>.from(actionsSnapshot.data()!["excluded"] ?? []);
      }

      // Luôn loại bỏ chính mình
      excludedIds.add(currentUserId);

      // 2. Query Firestore: lấy tất cả user trừ excludedIds
      QuerySnapshot snapshot = await _firestore.collection("users").get();

      List<UsersModel> allUsers = snapshot.docs
          .map((doc) => UsersModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((u) => !excludedIds.contains(u.id))
          .toList();

      // 3. Shuffle → lấy ngẫu nhiên 10 user
      allUsers.shuffle();
      return allUsers.take(10).toList();

    } catch (e) {
      print("ERROR getRandomUsers: $e");
      return [];
    }
  }

}
