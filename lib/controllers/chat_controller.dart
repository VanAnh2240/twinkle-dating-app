import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/models/chat_model.dart';
import 'package:twinkle/models/messages_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();
  final Uuid _uuid = Uuid();
  ChatsModel? _chatCache;

  ScrollController? _scrollController;
  ScrollController get scrollController {
    _scrollController ??= ScrollController();
    return _scrollController!;
  }
  
  final RxList<MessagesModel> _messages = <MessagesModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSending = false.obs;
  final RxString _error = ''.obs;
  final Rx<UsersModel?> _otherUser = Rx<UsersModel?>(null);
  final RxString _chatID = ''.obs;
  final RxBool _isTyping = false.obs;
  final RxBool _isChatActive = false.obs;

  List<MessagesModel> get messsages => _messages;
  bool get isLoading => _isLoading.value;
  bool get isSending => _isSending.value;
  String get error => _error.value;
  UsersModel? get otherUser => _otherUser.value;
  String get chatID => _chatID.value;
  bool get isTyping => _isTyping.value;

  @override
  void onInit() {
    super.onInit();
    _initializedChat();
    messageController.addListener(_onMessageChanged);
  }
  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  void onClose() {
    _isChatActive.value = false;
    _markMessageAsRead();
    messageController.removeListener(_onMessageChanged);
    messageController.dispose();
    _scrollController?.dispose();
    _scrollController = null;
    super.onClose();
  }

  void _initializedChat() {
    final arg = Get.arguments;
    print("🔍 Chat arguments: $arg");
    
    if (arg != null) {
      _chatID.value = arg['chat_id'] ?? '';
      _otherUser.value = arg['other_user'];
      
      print("🔍 Chat initialized - ID: ${_chatID.value}, Other user: ${_otherUser.value?.user_id}");
      
      if (_otherUser.value == null) {
        print("❌ Other user is null!");
        Get.snackbar("Error", "Cannot load chat user");
        return;
      }
      
      _isChatActive.value = true;
      _loadMessages();
      _markMessageAsRead();
    }
  }
  
  void _loadMessages() {
    final currentUserID = _authController.user?.uid;
    final otherUserID = _otherUser.value?.user_id;

    if (currentUserID != null && otherUserID != null) {
      _messages.bindStream(
        _firestoreService.getMessagesStream(currentUserID, otherUserID)
      );
    }

    ever(_messages, (List<MessagesModel> messageList) {
      if (_isChatActive.value) {
        _markUnReadMessageAsRead(messageList);
      }

      _scrollToBottom();
    });
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController != null && _scrollController!.hasClients) {
        _scrollController!.animateTo(
          _scrollController!.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  Future<void> _markUnReadMessageAsRead(List<MessagesModel> msgList) async {
    final currentUserID = _authController.user?.uid;
    if (currentUserID == null) return;

    try {
      final unreadMessages = msgList.where((message) => 
        message.receiver_id == currentUserID && 
        !message.is_read && 
        message.sender_id != currentUserID
      ).toList();

      for (var msg in unreadMessages) {
        await _firestoreService.markMessageAsRead(msg.message_id);
      }

      if (unreadMessages.isNotEmpty && _chatID.value.isNotEmpty) {
        await _firestoreService.restoreChatForUser(_chatID.value, currentUserID);
        await _firestoreService.restoreUnreadCount(_chatID.value, currentUserID);
      }
    } catch (e) {
      print("❌ Error markUnReadMessageAsRead: ${e.toString()}");
    }
  }

  Future<void> deleteChat(ChatsModel chat) async {
    try {
      final currentUserID = _authController.user?.uid;
      if (currentUserID == null || _chatID.value.isEmpty) return;

      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text("Delete chat"),
          content: Text("Are you sure you want to delete this chat? This action cannot be undone"),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false), 
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Get.back(result: true), 
              child: Text("Delete"),
            ),
          ],
        ),
      );

      if (result == true) {
        _isLoading.value = true;
        await _firestoreService.deleteChatForUser(_chatID.value, currentUserID);

        Get.delete<ChatController>(tag: _chatID.value);
        Get.back();
        Get.snackbar("Success", "Chat deleted");
      }
    } catch (e) {
      _error.value = e.toString();
      print("❌ Error deleting chat: $e");
      Get.snackbar("Error", "Failed to delete chat");
    } finally {
      _isLoading.value = false;
    }
  }

  void _onMessageChanged() {
    _isTyping.value = messageController.text.isNotEmpty;
  }

  Future<void> sendMessage() async {
    final currentUserID = _authController.user?.uid;
    final otherUserID = _otherUser.value?.user_id;
    final text = messageController.text.trim();

    print("🔍 Sending message - Current: $currentUserID, Other: $otherUserID, Text length: ${text.length}");

    if (currentUserID == null || otherUserID == null || text.isEmpty) {
      Get.snackbar("Error", 'You cannot send messages to this user');
      return;
    }

    try {
      _isSending.value = true;

      // Kiểm tra blocked/unmatched
      final isBlocked = await _firestoreService.isUserBlocked(currentUserID, otherUserID);
      final isUnmatched = await _firestoreService.isUserUnmatched(currentUserID, otherUserID);
      
      print("🔍 Block status: $isBlocked, Unmatch status: $isUnmatched");

      if (isBlocked || isUnmatched) {
        Get.snackbar("Error", 'You cannot send messages to this user anymore');
        messageController.text = text; // Restore text
        return;
      }

      // Clear message sau khi validate thành công
      messageController.clear();

      final message = MessagesModel(
        message_id: _uuid.v4(), 
        sender_id: currentUserID, 
        receiver_id: otherUserID, 
        message_text: text, 
        sent_at: DateTime.now()
      );

      print("📤 Attempting to send message: ${message.message_id}");
      await _firestoreService.sendMessage(message);
      print("✅ Message sent successfully");

      _isTyping.value = false;

    } catch (e) {
      print("❌ Error sending message: $e");
      Get.snackbar("Error", 'Failed to send message: ${e.toString()}');
      messageController.text = text; // Restore text on error
    } finally {
      _isSending.value = false;
    }
  }
  
  void _markMessageAsRead() async {
    final currentUserID = _authController.user?.uid;
    
    if (currentUserID != null && _chatID.value.isNotEmpty) {
      try {
        await _firestoreService.restoreChatForUser(_chatID.value, currentUserID);
      } catch (e) {
        print("❌ Error marking messages as read: $e");
      }
    }
  }

  void onChatResumed() {
    _isChatActive.value = true;
    _markUnReadMessageAsRead(_messages);
  }

  void onChatPaused() {
    _isChatActive.value = false;
  }

  bool isMyMessage(MessagesModel message) {
    return message.sender_id == _authController.user?.uid;
  }

  String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return "Just now";
    }
    else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    }
    else if (diff.inDays < 1) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    else if (diff.inDays < 7) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[timestamp.weekday - 1]} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void clearError() {
    _error.value = '';
  }
}