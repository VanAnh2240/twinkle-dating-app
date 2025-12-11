import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/message_controller.dart';
import '../controllers/match_controller.dart';
import '../services/user_service.dart';

class ChatListPage extends StatelessWidget {
  final MatchController matchController = Get.put(MatchController());
  final MessageController messageController = Get.put(MessageController());
  final UserService userService = UserService(); // để fetch user info

  @override
  Widget build(BuildContext context) {
    messageController.listenChatRooms(); // lắng nghe danh sách chat room

    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (matchController.chatRooms.isEmpty) {
          return Center(
            child: Text(
              "No chats yet",
              style: TextStyle(fontSize: 17, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: matchController.chatRooms.length,
          itemBuilder: (context, index) {
            String roomId = matchController.chatRooms[index];

            return FutureBuilder<Map<String, dynamic>>(
              future: _buildChatRoomData(roomId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return ListTile(
                    title: Text("Loading..."),
                  );
                }

                final data = snapshot.data!;
                final otherUser = data["otherUser"];
                final chatInfo = data["chatInfo"];

                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(otherUser["profile_picture"] ?? ""),
                  ),
                  title: Text(
                    "${otherUser['first_name']} ${otherUser['last_name']}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    chatInfo["is_active"] == false
                        ? "Unmatched — cannot send messages"
                        : chatInfo["last_message"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatTimestamp(chatInfo['last_message_time']),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    if (chatInfo["is_active"] == false) {
                      Get.snackbar("Unavailable", "You cannot chat with this user anymore");
                      return;
                    }

                    Get.toNamed("/chat", arguments: {
                      "chatroomId": roomId,
                      "otherUser": otherUser,
                    });
                  },
                );
              },
            );
          },
        );
      }),
    );
  }

  /// 🔥 Lấy dữ liệu chat room + data của đối phương
  Future<Map<String, dynamic>> _buildChatRoomData(String roomId) async {
    final roomSnap =
        await FirebaseFirestore.instance.collection("chat_rooms").doc(roomId).get();
    final roomData = roomSnap.data()!;

    // xác định ID của đối phương
    String currentUser = FirebaseAuth.instance.currentUser!.uid;
    List users = roomData["users"];
    String otherId = users.firstWhere((id) => id != currentUser);

    // lấy thông tin user kia
    final otherUser = await userService.getUserById(otherId);

    return {
      "chatInfo": roomData,
      "otherUser": otherUser,
    };
  }

  /// 📌 format thời gian hiển thị
  String _formatTimestamp(Timestamp? t) {
    if (t == null) return "";
    final dt = t.toDate();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
