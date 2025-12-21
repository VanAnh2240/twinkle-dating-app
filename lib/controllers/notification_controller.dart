// ** Từ image_7e41e2.png **
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/models/notifications_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/services/firestore_service.dart';

class NotificationController extends GetxController {
  final FirestoreService firestoreService = FirestoreService();
  final AuthController authController = Get.find<AuthController>();
  
  final RxList<NotificationsModel> _notifications = <NotificationsModel>[].obs;
  final RxMap<String, UsersModel> _users = <String, UsersModel>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  List<NotificationsModel> get notifications => _notifications;
  Map<String, UsersModel> get users => _users;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications(); 
    _loadUsers();
  }
  
  void _loadNotifications() {
    final currentUserId = authController.user?.uid;
    if (currentUserId != null) {
      _notifications.bindStream(firestoreService.getNotificationsStream(currentUserId));
    }
  }
  
  void _loadUsers() {
    _users.bindStream(firestoreService.getAllUsersStream().map((userList) {
      Map<String,UsersModel> userMap = {};
      for (var user in userList) {
        userMap[user.user_id] = user;
      }
      return userMap;
    }));
  }

  UsersModel? getUser(String userId){
    return _users[userId];
  }


  Future<void> markAsRead(NotificationsModel notification) async {
    try{
      if(!notification.is_read) {
        await firestoreService.markAllNotificationAsRead(notification.notification_id);
      }
    }catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to mark as read');
      print(e.toString());
    }
  }  

  Future<void> markAllAsRead() async {
    try {
      _isLoading.value = true;
      final currentUserId = authController.user?.uid;
      
      if (currentUserId != null) {
        await firestoreService.markAllNotificationAsRead(currentUserId);
        //Get.snackbar('Success', 'All notifications marked as read');
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to mark all as read');
      print(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }  

  void handleNotificationTap(NotificationsModel notification) {
    markAsRead(notification);
    Get.back();
  }

  String getNotificationTimeText(DateTime createAt) {
    final now = DateTime.now();
    final difference = now.difference(createAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago'; 
    } else {
      return '${createAt}/${createAt}/${createAt}';
    }
  }

  int getUnreadCount(){
    return _notifications.where((notification) => !notification.is_read).length;
  }
  

  void clearError(){
    _error.value = '';
  }

}
