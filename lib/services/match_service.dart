import 'package:cloud_firestore/cloud_firestore.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createMatch(String user1, String user2) async {
    List<String> ids = [user1, user2];
    ids.sort();
    String chatroomId = ids.join("_");

    try {
      // Store match info
      await _firestore.collection("Matches").add({
        "user1_id": user1,
        "user2_id": user2,
        "matched_at": DateTime.now(),
      });

      // Create chat room
      await _firestore.collection("ChatRooms").doc(chatroomId).set({
        "user1_id": user1,
        "user2_id": user2,
        "is_active": true,
        "created_at": DateTime.now(),
        "last_message": "",
        "last_message_time": DateTime.now(),
      });
    } catch (e) {
      throw Exception("Failed to create match: $e");
    }
  }

  // Get user chat rooms
  Stream<List<String>> getUserChatRooms(String userId) {
    return _firestore
      .collection("ChatRooms")
      .where("Users", arrayContains: userId)
      .snapshots()
      .map((snap) => snap.docs.map((e) => e.id).toList());
  }

  // Unmatch => không xoá chat, chỉ disable gửi tin nhắn
  Future<void> unMatch(String user1, String user2) async {
    List<String> ids = [user1, user2];
    ids.sort();
    String chatroomId = ids.join("_");

    await _firestore.collection("ChatRooms").doc(chatroomId).update({
      "is_active": false,
    });
  }
}
