import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/chat_controller.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/models/chat_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/themes/theme.dart';

class ChatListItem extends StatelessWidget {
  final ChatsModel chat;
  final UsersModel otherUser;
  final String lastMessageTime;
  final VoidCallback onTap;
  
  const ChatListItem({
    super.key,
    required this.chat,
    required this.otherUser,
    required this.lastMessageTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final chatController = Get.find<ChatController>();
    final currentUserId = authController.user?.uid ?? '';
    final unreadCount = chat.getUnreadCount(currentUserId);
    final displayName = '${otherUser.first_name} ${otherUser.last_name}';                        
                        
    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showChatOptions(context, chatController), 
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor,
                    child: otherUser.profile_picture.isNotEmpty       
                      
                      //Avatar
                      ?ClipOval
                      (
                        child: Image.network(
                          otherUser.profile_picture,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error,StackTrace) {
                            return Text(
                              displayName.isNotEmpty 
                                ? displayName
                                : "?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      )
                      : 

                      // display name
                      Text(
                        displayName.isNotEmpty 
                          ? displayName
                          : "?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                  ),

                  //online status
                  if (otherUser.is_online)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          border: Border.all(color: AppTheme.borderColor, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    )
                ], 
              ), 

              SizedBox(width: 10,),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //last message
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        //Unread  count
                        Expanded(
                          child: Text(
                            displayName,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: unreadCount > 0 
                                ?FontWeight.bold
                                :FontWeight.normal
                            ),
                            overflow: TextOverflow.ellipsis,
                          ), 
                        ),


                        //last message time
                        if (lastMessageTime.isNotEmpty)
                          Text(
                            lastMessageTime,
                            style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: unreadCount > 0
                                  ? AppTheme.textPrimaryColor
                                  : AppTheme.textSecondaryColor,
                                
                                fontWeight: unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              )
                          )
                      ],
                    ),

                    SizedBox(height: 4),

                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              
                              // status icons
                              if (chat.last_message_sender_id == currentUserId) ...[
                                Icon(
                                  _getSeenStatusIcon(),
                                  size: 14,
                                  color: _getSeenStatusColor(),
                                ),

                                SizedBox(width: 4),
                              ],

                              // last message
                              Expanded(
                                child: Text(
                                  chat.last_message ?? "No messages yet",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: unreadCount > 0 
                                      ? AppTheme.textPrimaryColor
                                      : AppTheme.textPrimaryColor,

                                    fontWeight: unreadCount > 0 
                                      ?FontWeight.bold
                                      :FontWeight.normal
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ), 
                              ),
                            ],
                          )
                        ),


                        if (unreadCount > 0) ...[
                          SizedBox(width: 8),
                          Container( 
                            child: Text(
                              unreadCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ), 
                            ), 
                          ), 
                        ], 
                      ],
                    ),

                    // chat.last_message_sender_id == currentUserId
                    if (chat.last_message_sender_id == currentUserId) ... [
                      SizedBox(height: 2,),
                      Text(
                        _getSeenStatusText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getSeenStatusColor(),
                          fontSize: 11,
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ], 
          ),
        ),
      ),
    );
  }

  IconData _getSeenStatusIcon() {
    final AuthController authController = Get.find<AuthController>();
    final currentUserId = authController.user?.uid ?? '';
    final otherUserId = chat.getOtherParticipant(currentUserId);

    if (chat.isMessageSeen(currentUserId, otherUserId)) {
      return Icons.done_all; //Seen
      
    } else {
      return Icons.done; //Sent 
    }
  }

  Color _getSeenStatusColor() {
    final AuthController authController = Get.find<AuthController>();
    final currentUserId = authController.user?.uid ?? '';
    final otherUserId = chat.getOtherParticipant(currentUserId);

    if (chat.isMessageSeen(currentUserId, otherUserId)) {
      return AppTheme.textPrimaryColor;
    } else {
      return AppTheme.textSecondaryColor;
    }
  }

  String _getSeenStatusText() {
    final AuthController authController = Get.find<AuthController>();
    final currentUserId = authController.user?.uid ?? '';
    final otherUserId = chat.getOtherParticipant(currentUserId);

    if (chat.isMessageSeen(currentUserId, otherUserId)) {
      return 'Seen';
    } else {
      return 'Sent';
    }
  }

  void _showChatOptions(BuildContext context, ChatController chatController) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.textSecondaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTeriaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ), 

            SizedBox(height: 20,),
            ListTile(
              leading: Icon(Icons.delete_outline,color: Colors.red,),
              title: Text("Delete chat?"),
              subtitle: Text("This will delete that chat for you only"),
              onTap: () {
                Get.back();
                chatController.deleteChat(chat);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,color: Colors.red,),
              title: Text("View profile"),
              onTap: () {
                Get.back();
              },
            ),
            
            SizedBox(height: 10,),
          ],
        ), 
      ), 
    );
  }

}