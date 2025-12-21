import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/models/chat_model.dart';
import 'package:twinkle/models/notifications_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/firestore_service.dart';

import '../routes/app_routes.dart';

class ChatListController extends GetxController{
  final FirestoreService firestoreService = FirestoreService();
  final AuthController authController =  Get.find<AuthController>(); 
  
  final RxList<ChatsModel> _allChats = <ChatsModel>[].obs;
  final RxList<ChatsModel>_filteredChats = <ChatsModel>[].obs;
  final RxList<NotificationsModel> _notifications = <NotificationsModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxMap<String, UsersModel> _users = <String, UsersModel>{}.obs;

  final RxString _searchQuery = ''.obs;
  final RxBool _isSearching = false.obs;
  final RxString _activeFilter = 'All'.obs;

  List <ChatsModel> get chats => _getFilteredChats();
  List<ChatsModel> get allChats => _allChats;
  List<ChatsModel> get filteredChats => _filteredChats;
  List<NotificationsModel> get notifications => _notifications;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  String get searchQuery => _searchQuery.value;
  bool get isSearching =>  _isSearching.value;


  @override
  void onInit() {
    super.onInit();
    _loadChats();
    _loadUsers();
    _loadNotifications();
  }

  void _loadChats() {
    final currentUserId = authController.user?.uid;
    
    if (currentUserId != null) {
      _allChats.bindStream(firestoreService.getUserChatsStream(currentUserId));

      ever(_allChats, (chats) {
        if (chats.isNotEmpty) {
        }
        
        if (_isSearching.value && _searchQuery.value.isNotEmpty) {
          _performSearch(_searchQuery.value);
        }
      });

      ever(_activeFilter, (_) {
        if (_searchQuery.value.isNotEmpty) {
          _performSearch(_searchQuery.value);
        }
      });
    } 
  }
  
  void _loadUsers() {
    _users.bindStream(
      firestoreService.getAllUsersStream().map((userList) {
        print("🔵 ChatListController: Users loaded - count: ${userList.length}");
        Map<String, UsersModel> userMap = {};
        for(var user in userList) {
          userMap[user.user_id] = user;
        }
        return userMap;
      }),
    );
  }

  void _loadNotifications() {
    final currentUserId = authController.user?.uid;
    
    if (currentUserId != null) {
      _notifications.bindStream(
        firestoreService.getNotificationsStream(currentUserId),
      );
    }
  }

  UsersModel? getOtherUser(ChatsModel chat) {
    final currentUserId = authController.user?.uid;
    if (currentUserId != null) {
      final otherUserId = chat.getOtherParticipant(currentUserId);
      final user = _users[otherUserId];
      
      return user;
    }
    return null;
  }

  String formatLastMessageTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  List<ChatsModel> _getFilteredChats() {
    List<ChatsModel> baseList = _isSearching.value ? _filteredChats : _allChats;
    
    switch (_activeFilter.value) {
      case 'Unread':
        final result = _applyUnreadFilter(baseList);
        return result;
      case 'Recent':
        final result = _applyRecentFilter(baseList);
        return result;
      case 'Active':
        final result = _applyActiveFilter(baseList);
        return result;
      case 'All':
      default:
        return baseList;
    }
  }

  List<ChatsModel> _applyUnreadFilter(List<ChatsModel> chats) {
    final currentUserId = authController.user?.uid;
    if (currentUserId == null) return [];

    return chats
        .where((chat) => chat.getUnreadCount(currentUserId) > 0)
        .toList();
  }

  List<ChatsModel> _applyRecentFilter(List<ChatsModel> chats) {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(Duration(days: 3));
    return chats.where((chat) {
      if (chat.last_message_time == null) return false;
      return chat.last_message_time!.isAfter(threeDaysAgo);
    }).toList();
  }

  List<ChatsModel> _applyActiveFilter(List<ChatsModel> chats) {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(Duration(days: 7));
    return chats.where((chat) {
      if (chat.last_message_time == null) return false;
      return chat.last_message_time!.isAfter(oneWeekAgo);
    }).toList();
  }

  void setFilter(String filterType) {
    _activeFilter.value = filterType;

    if (filterType == 'All') {
      if (_searchQuery.value.isEmpty) {
        _isSearching.value = false;
        _filteredChats.clear();
      }
    }
  }

  void clearAllFilters() {
    _activeFilter.value = 'All';
    _clearSearch();
  }

  void onSearchChanged(String query) {
    _searchQuery.value = query;
    if (query.isEmpty) {
      _clearSearch();
    } else {
      _isSearching.value = true;
      _performSearch(query);
    }
  }

  void _performSearch(String query) {
    final lowercaseQuery = query.toLowerCase().trim();
   
    _filteredChats.value = _allChats.where((chat) {
      final otherUser = getOtherUser(chat);
      if (otherUser == null) return false;

      final displayName = '${otherUser.first_name} ${otherUser.last_name}';
      
      final displayNameMatch =
          displayName.toLowerCase().contains(lowercaseQuery);

      final emailMatch =
          otherUser.email?.toLowerCase().contains(lowercaseQuery) ?? false;

      final lastMessageMatch =
          chat.last_message?.toLowerCase().contains(lowercaseQuery) ?? false;

      return displayNameMatch || emailMatch || lastMessageMatch;
    }).toList();

    print("🔵 _performSearch: Found ${_filteredChats.length} results");
    _sortSearchResults(lowercaseQuery);
  }

  void _sortSearchResults(String query) {
    _filteredChats.sort((a, b) {
      final userA = getOtherUser(a);
      final userB = getOtherUser(b);

      if (userA == null || userB == null) return 0;
      
      final lowercaseQuery = query.toLowerCase().trim(); 

      final displayNameA = '${userA.first_name} ${userA.last_name}';
      final exactMatchA = displayNameA.toLowerCase().startsWith(lowercaseQuery);

      final displayNameB = '${userB.first_name} ${userB.last_name}';
      final exactMatchB = displayNameB.toLowerCase().startsWith(lowercaseQuery);

      if (exactMatchA && !exactMatchB) return -1;
      if (!exactMatchA && exactMatchB) return 1;

      return (b.last_message_time ?? DateTime(0)).compareTo(
          a.last_message_time ?? DateTime(0),
      );
    });
  }
  
  void _clearSearch() {
    _isSearching.value = false;
    _filteredChats.clear();
  }

  void clearSearch() {
    _searchQuery.value = "";
    _clearSearch();
  }

  void searchUserByName(String name) {
    onSearchChanged(name);
  }
  
  void seacrchUserByLastMessage(String message) {
    onSearchChanged(message);
  }
  
  List<ChatsModel> getUnreadChats() {
    return _applyUnreadFilter(chats);
  }

  List<ChatsModel> getActiveChats() {
    return _applyRecentFilter(_allChats);
  }

  List<ChatsModel> getRecentChats({int limit = 10}) {
    final recentChats = _applyRecentFilter(_allChats);
    
    final sortedChats = List<ChatsModel>.from(recentChats);
    sortedChats.sort((a, b) {
      return (b.last_message_time ?? DateTime(0)).compareTo(
          a.last_message_time ?? DateTime(0),
      );
    });
    
    return sortedChats.take(limit).toList();
  }

  int getUnreadCount() {
    return getUnreadChats().length;
  }

  int getRecentCount() {
    return _applyRecentFilter(_allChats).length;
  }

  int getActiveCount() {
    return getActiveChats().length;
  }

  void openChat(ChatsModel chat) {
    final otherUser = getOtherUser(chat);
      
    if (otherUser != null) {
      Get.toNamed(
        AppRoutes.chat,
        arguments: {
          'chat_id': chat.chat_id,     
          'other_user': otherUser,      
        },
      );
    } else {
      Get.snackbar(
        "Error", 
        "Cannot load user information",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openMatches() {
    Get.toNamed(AppRoutes.match);
  }

  void openNotifications() {
    Get.toNamed(AppRoutes.notification);
  }

  Future<void> refreshChats() async {
    _isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 1));
    }catch(e) { 
      _error.value = 'Failed to refresh chats';
    }finally {
      _isLoading.value = false;
    }
  }

  int getTotalUnreadCount() {
    final currentUserId = authController.user?.uid;
    if (currentUserId == null) return 0;
    
    int total = 0;
    for (var chat in _allChats) {
      total += chat.getUnreadCount(currentUserId);
    }
    return total;
  }

  int getUnreadNotificationsCount(){
    return notifications.where((noti) => !noti.is_read).length;
  }

  Future<void> deleteChat(ChatsModel chat) async {
    try{
      final currentUserID = authController.user?.uid;
      if(currentUserID == null) return;

      final otherUser = getOtherUser(chat);
      final displayName = '${otherUser?.first_name} ${otherUser?.last_name}';

      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Delete Chat'),
          content: Text(
            'Are you sure you want to delete the chat with ${displayName ?? 'this user'}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        )
      );

      if (result == true) {
        await firestoreService.deleteChatForUser(chat.chat_id, currentUserID);
        Get.snackbar('Success', 'Chat deleted successfully');
      }

    }catch (e){
      Get.snackbar('Error', 'Failed to delete chat');
    }finally {
      _isLoading.value = false;
    }
  }

  void clearError(){
    _error.value ='';
  }

  @override
  void onClose() {
    super.onClose();
  }
}