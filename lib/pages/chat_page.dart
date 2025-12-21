import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/components/chatting/message_bubble.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/controllers/chat_controller.dart';
import 'package:twinkle/models/chat_model.dart';
import 'package:twinkle/themes/theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  late final String chatID;
  late final ChatController controller;
  late final TextEditingController messageController; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    chatID = Get.arguments?['chat_id'] ?? '';

    if (!Get.isRegistered<ChatController>(tag: chatID)) {
      Get.put<ChatController>(ChatController(), tag: chatID);
    }

    controller = Get.find<ChatController>(tag: chatID);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        controller.onChatResumed();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        controller.onChatPaused();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 14, 14),
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 15,
        backgroundColor: Color.fromARGB(255, 119, 102, 147).withOpacity(0.65),
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            Get.back();  
            await Future.delayed(Duration(milliseconds: 100));
            Get.delete<ChatController>(tag: chatID, force: true);
          }, 
          icon: Icon(Icons.arrow_back, color: Colors.white)
        ),
        title: Obx(() {
          final otherUser = controller.otherUser;
          if (otherUser == null) {
            return Text(
              'Chat', 
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.start,
            );
          }
          
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${otherUser.first_name} ${otherUser.last_name}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      otherUser.is_online ? "Active now" : "Offline",
                      style: TextStyle(
                        color: otherUser.is_online 
                          ? Color.fromARGB(255, 251, 240, 240)
                          : Color(0xFF6B6B6B),
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                )
              )
            ],
          );
        }),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF4A7BC8),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.videogame_asset, color: Colors.white, size: 25),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF4A7BC8),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.call, color: Colors.white, size: 25),
            ),
          ),
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF4A7BC8),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.more_horiz, color: Colors.white, size: 25),
            ),
            onPressed: () {
              _showOptionsBottomSheet(context, controller, chatID);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.messsages.isEmpty) {
                return _buildEmptyState();
              }
              
              return ListView.builder(
                controller: controller.scrollController,
                padding: EdgeInsets.all(16),
                itemCount: controller.messsages.length,
                itemBuilder: (context, index) {
                  final message = controller.messsages[index];
                  final isMyMessage = controller.isMyMessage(message);
                  final showTime = index == 0 || 
                    controller.messsages[index - 1].sent_at
                      .difference(message.sent_at).inMinutes.abs() >= 5;
                  
                  return MessageBubble(
                    message: message,
                    isMyMessage: isMyMessage,
                    showTime: showTime,
                    timeText: controller.formatMessageTime(message.sent_at),
                  );
                }
              );
            })
          ),
          _buildMessagesInput(),
        ],
      )
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFF4A7BC8).withOpacity(0.2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: AppTheme.primaryColor,
                size: 40,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Start the conversation", 
              style: TextStyle(
                color: AppTheme.secondaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w600
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Send a message to get chat started", 
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 14
              ),  
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMessagesInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 33, 32, 32),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Obx(
                    () => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: controller.isTyping
                            ? Colors.white.withOpacity(0.95)
                            : Colors.grey.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: GetBuilder<ChatController>(
                      tag: chatID,
                      builder: (ctrl) {
                        if (!Get.isRegistered<ChatController>(tag: chatID)) {
                          return SizedBox.shrink();
                        }
                        return TextField(
                          key: ValueKey('textfield_$chatID'),
                          controller: ctrl.messageController,
                          cursorColor: AppTheme.secondaryColor,
                          selectionControls: materialTextSelectionControls,
                          style: const TextStyle(
                            color: AppTheme.textTeriaryColor,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: "Say something...",
                            hintStyle: const TextStyle(
                              color: Colors.black45,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppTheme.textPrimaryColor,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(0, 239, 211, 211),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 2,
                              ),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          ),
                          maxLines: null,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => ctrl.sendMessage(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: controller.isTyping
                      ? AppTheme.secondaryColor                    
                      : AppTheme.textSecondaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: controller.isTyping && !controller.isSending
                      ? controller.sendMessage
                      : null,
                  icon: controller.isSending
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context, ChatController controller, String chatID) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Options',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            
            _buildOptionButton(
              text: 'Block this person',
              onTap: () {
                Get.back();
                _showBlockConfirmDialog(controller);
              },
            ),
            SizedBox(height: 12),
             
            _buildOptionButton(
              text: 'Unmatch',
              onTap: () {
                Get.back();
                _showUnmatchDialog(controller);
              },
            ),
            SizedBox(height: 12),
            
            _buildOptionButton(
              text: 'Delete chat',
              onTap: () async {
                Get.back();
                final currentUserID = Get.find<AuthController>().user?.uid ?? '';
                final otherUserID = controller.otherUser?.user_id ?? '';
                
                final chat = ChatsModel(
                  chat_id: chatID,
                  participants: [currentUserID, otherUserID],
                  unread_count: {},
                  created_at: DateTime.now(),
                  updated_at: DateTime.now(),
                );
                await controller.deleteChat(chat);
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showBlockConfirmDialog(ChatController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Color(0xFF2A2A2A),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Block this person?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "This person won't be able to see or text\nyou again!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 24),
              
              InkWell(
                onTap: () async {
                  Get.back(); // Đóng dialog
                  
                  final currentUserID = Get.find<AuthController>().user?.uid;
                  final otherUser = controller.otherUser;
                  
                  if (currentUserID == null || otherUser == null) {
                    Get.snackbar(
                      "Error", 
                      "Cannot block user",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  try {
                    // Show loading
                    Get.dialog(
                      Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );

                    // Block user trong Firestore
                    await controller.blockUser(currentUserID, otherUser.user_id);

                    // Close loading
                    Get.back();
                    
                    // Close chat page và quay về trang trước
                    Get.back();
                    Get.delete<ChatController>(tag: chatID, force: true);
                    
                    Get.snackbar(
                      "Success", 
                      "User blocked successfully",
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    // Close loading nếu có lỗi
                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }
                    
                    Get.snackbar(
                      "Error", 
                      "Failed to block user: ${e.toString()}",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Block!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              
              InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnmatchDialog(ChatController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Color(0xFF2A2A2A),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unmatch?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "You guys won't be able to see or text\neach other again!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 24),
              
              InkWell(
                onTap: () async {
                  Get.back();
                  
                  final currentUserID = Get.find<AuthController>().user?.uid;
                  final otherUser = controller.otherUser;
                  
                  if (currentUserID == null || otherUser == null) {
                    Get.snackbar(
                      "Error", 
                      "Cannot unmatch user",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  try {
                    Get.dialog(
                      Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );

                    await controller.unmatchUser(currentUserID, otherUser.user_id);

                    Get.back(); // Close loading
                    Get.back(); // Close chat page
                    Get.delete<ChatController>(tag: chatID, force: true);
                    
                    Get.snackbar(
                      "Success", 
                      "Unmatched successfully",
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }
                    
                    Get.snackbar(
                      "Error", 
                      "Failed to unmatch: ${e.toString()}",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Unmatch',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              
              InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}