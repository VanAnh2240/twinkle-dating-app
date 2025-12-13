import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/chat_controller.dart';
import 'package:twinkle/themes/theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  late final String chatID;
  late final ChatController chatController;

  @override
  void initState() {
    super.initState();
    chatID = Get.arguments?['chat_id']?? '';

    if (!Get.isRegistered<ChatController>(tag: chatID)) {
      Get.put<ChatController>(ChatController(), tag: chatID);
    }

    chatController = Get.find<ChatController>(tag:chatID);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Get.delete<ChatController>(tag:chatID);
            Get.back();
          }, 
          icon: Icon(Icons.arrow_back)),

          title: Obx((){
            final otherUser = chatController.otherUser;
            if (otherUser == null) return Text('Chat');
            return Row(
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    //display name
                    Text(
                      otherUser.first_name + otherUser.last_name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),

                    //status
                    Text(
                      otherUser.is_online ? "Active now" : "Offline",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: otherUser.is_online ? AppTheme.textPrimaryColor 
                          : AppTheme.textSecondaryColor
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ))
              ],
            );
          }),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                switch(value){
                  case 'delete':
                  chatController.deleteChat();
                  break;
                }
              }, 
              itemBuilder: (context) => [
                 PopupMenuItem(
                   value: 'delete',
                   child: ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                        color: AppTheme.errorColor,
                      ),
                      title: Text('Delete chat'),
                      contentPadding: EdgeInsets.zero,
                   ),
                 ),
              ],
            ),
          ],
      ),
    );
  }
}