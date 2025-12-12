import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twinkle/models/users_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user FirebaseAuth
  Future<void> createUser(String uid, UsersModel user) async {
    try {
      final data = user.toMap();

      if (data['last_seen'] is DateTime) {
        data['last_seen'] = Timestamp.fromDate(data['last_seen']);
      }
      if (data['created_at'] is DateTime) {
        data['created_at'] = Timestamp.fromDate(data['created_at']);
      }
      await _firestore.collection('Users').doc(uid).set(user.toMap());
    } catch (e) {
      throw Exception("Failed to create user: $e");
    }
  }

  // Get user by uid
  Future<UsersModel> getUserById(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection("Users")
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


  //get users
  Future<List<UsersModel>> getUsers(String currentUserId) async {
    try {
      // get all collection 'Users'
      QuerySnapshot snapshot = await _firestore.collection('Users').get();

      // map to UsersModel and exclude current user
      List<UsersModel> users = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['user_id'] = doc.id; // thêm user_id từ document ID
        return UsersModel.fromMap(data);
      }).where((user) => user.id != currentUserId).toList();

      return users;
    } catch (e) {
      print("Error getUsers: $e");
      return [];
    }
  }

}
