import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/message_controller.dart';
import '../controllers/match_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/messages_model.dart';

class ChatPage extends StatelessWidget {
  final MatchController matchController = Get.put(MatchController());
  final MessageController messageController = Get.put(MessageController());
  final AuthController authController = Get.find<AuthController>();

  final ScrollController scrollController = ScrollController();
  final messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String chatroomId = args["chatroomId"];
    final Map<String, dynamic> otherUser = args["otherUser"];

    messageController.listenChatRooms(); // để load realtime

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(otherUser["profile_picture"] ?? ""),
            ),
            SizedBox(width: 10),
            Text(
              "${otherUser['first_name']} ${otherUser['last_name']}",
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessagesModel>>(
              stream: messageController.getMessages(chatroomId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scrollController.hasClients) {
                    scrollController.jumpTo(
                      scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isMe = msg.sender_id == authController.user!.uid;

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: Get.width * 0.7),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          msg.message_text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          _buildMessageInput(chatroomId, otherUser["user_id"]),
        ],
      ),
    );
  }

  /// 🔥 Input box + send button
  Widget _buildMessageInput(String chatroomId, String receiverId) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageTextController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
          ),
          SizedBox(width: 8),

          /// SEND BUTTON
          GestureDetector(
            onTap: () async {
              final text = messageTextController.text.trim();
              if (text.isEmpty) return;

              await messageController.sendMessage(chatroomId, receiverId, text);

              messageTextController.clear();
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue,
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
