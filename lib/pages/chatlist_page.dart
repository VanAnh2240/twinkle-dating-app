import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/components/chatting/chat_list.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/controllers/chatlist_controller.dart';
import 'package:twinkle/controllers/chat_controller.dart';
import 'package:twinkle/controllers/main_controller.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/themes/theme.dart';
import 'package:twinkle/services/profile_service.dart';
import 'package:twinkle/models/profile_model.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late ChatListController controller;
  final TextEditingController _searchController = TextEditingController();
  bool _ignoreOnChange = false;
  final ChatController chatlistController = Get.put(ChatController());
  final ProfileService _profileService = ProfileService();
  
  // Cache profiles để tránh load lại nhiều lần
  final Map<String, ProfileModel?> _profileCache = {};

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChatListController());
  }
  
  @override
  void dispose() {
    Get.delete<ChatListController>();
    _searchController.dispose();
    super.dispose();
  }

  // Lấy profile từ cache hoặc load mới
  Future<ProfileModel?> _getProfile(String userId) async {
    // Kiểm tra cache trước
    if (_profileCache.containsKey(userId)) {
      return _profileCache[userId];
    }

    // Load từ service nếu chưa có trong cache
    try {
      final profile = await _profileService.getProfile(userId);
      _profileCache[userId] = profile;
      return profile;
    } catch (e) {
      print('Error loading profile for $userId: $e');
      _profileCache[userId] = null;
      return null;
    }
  }

  // Widget hiển thị avatar với FutureBuilder
  Widget _buildAvatar(String userId, {double size = 56}) {
    return FutureBuilder<ProfileModel?>(
      future: _getProfile(userId),
      builder: (context, snapshot) {
        // Nếu đang load
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.secondaryColor,
            ),
            child: Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          );
        }

        // Lấy avatar URL từ profile
        final profile = snapshot.data;
        final avatarUrl = profile?.photos.isNotEmpty == true 
            ? profile!.photos.first 
            : null;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.secondaryColor,
          ),
          child: ClipOval(
            child: _buildAvatarImage(avatarUrl, size),
          ),
        );
      },
    );
  }

  // Widget xử lý hiển thị ảnh (Network hoặc File)
  Widget _buildAvatarImage(String? avatarUrl, double size) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return Icon(
        Icons.person, 
        size: size * 0.5, 
        color: Colors.white54,
      );
    }

    // Kiểm tra nếu là URL network
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading network image: $error');
          return Icon(
            Icons.person, 
            size: size * 0.5, 
            color: Colors.white54,
          );
        },
      );
    }

    // Nếu là local file path
    try {
      final file = File(avatarUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading file image: $error');
            return Icon(
              Icons.person, 
              size: size * 0.5, 
              color: Colors.white54,
            );
          },
        );
      } else {
        print('File does not exist: $avatarUrl');
        return Icon(
          Icons.person, 
          size: size * 0.5, 
          color: Colors.white54,
        );
      }
    } catch (e) {
      print('Error accessing file: $e');
      return Icon(
        Icons.person, 
        size: size * 0.5, 
        color: Colors.white54,
      );
    }
  }
   
  @override  
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    
    return Scaffold(
      appBar: _buildAppBar(context, authController),
      body: Obx(() {
        final hasAnyChats = controller.allChats.isNotEmpty;
        final isSearching = controller.isSearching && controller.searchQuery.isNotEmpty;
        final chatList = isSearching ? controller.filteredChats : controller.chats;

        // Nếu không có chat nào trong database
        if (!hasAnyChats) {
          return Center(
            child: _buildEmptyState(),
          );
        }

        // Nếu có chat trong database
        return Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: () async {
                  // Clear cache khi refresh
                  _profileCache.clear();
                  await controller.refreshChats();
                },
                child: chatList.isEmpty
                    ? _buildNoResultsOrEmpty(isSearching)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: chatList.length,
                        itemBuilder: (context, index) {
                          final chat = chatList[index];
                          final otherUser = controller.getOtherUser(chat);
                          if (otherUser == null) return const SizedBox.shrink();
                          
                          return _buildChatListItem(chat, otherUser);
                        },
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Custom ChatListItem với avatar từ profile
  Widget _buildChatListItem(chat, otherUser) {
    final currentUserId = controller.authController.user?.uid;
    final unreadCount = currentUserId != null 
        ? chat.getUnreadCount(currentUserId) 
        : 0;

    return InkWell(
      onTap: () => controller.openChat(chat),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            // Avatar với profile photo
            _buildAvatar(otherUser.user_id),
            const SizedBox(width: 12),
            
            // Thông tin chat
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${otherUser.first_name} ${otherUser.last_name}',
                          style: TextStyle(
                            color: AppTheme.textPrimaryColor,
                            fontSize: 16,
                            fontWeight: unreadCount > 0 
                                ? FontWeight.bold 
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.formatLastMessageTime(chat.last_message_time),
                        style: TextStyle(
                          color: unreadCount > 0 
                              ? AppTheme.primaryColor 
                              : AppTheme.textSecondaryColor,
                          fontSize: 12,
                          fontWeight: unreadCount > 0 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.last_message ?? 'No messages yet',
                          style: TextStyle(
                            color: unreadCount > 0 
                                ? AppTheme.textPrimaryColor 
                                : AppTheme.textSecondaryColor,
                            fontSize: 14,
                            fontWeight: unreadCount > 0 
                                ? FontWeight.w500 
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Unread badge
                      if (unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(minWidth: 20),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Handle both search no results and filter no results
  Widget _buildNoResultsOrEmpty(bool isSearching) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 100),
        if (isSearching)
          _buildNoSearchResults()
        else
          _buildNoFilterResults(),
      ],
    );
  }

  // Show when filter returns no results
  Widget _buildNoFilterResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_off,
                size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            Text(
              "No chats match this filter",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your filter or start a new conversation',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AuthController authController) {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      foregroundColor: AppTheme.textPrimaryColor,
      elevation: 0,
      title: Obx(
        () => Text(
          controller.isSearching ? 'Search results' : "Messages",
        ),
      ),
      automaticallyImplyLeading: false,
      actions: [
        Obx(() => 
          controller.isSearching 
            ? IconButton(onPressed: controller.clearSearch, icon: Icon(Icons.clear_rounded)) 
            : _buildNotificationButton(),
        )
      ],
    );
  }
  
  Widget _buildNotificationButton() {
    return Obx(() {
      final unreadNotifications = controller.getUnreadNotificationsCount();

      return Container(
        margin: EdgeInsets.only(right: 8),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(32),
              ),
              child: IconButton(
                onPressed: controller.openNotifications, 
                icon: Icon(Icons.notifications_outlined),
                iconSize: 28,
                splashRadius: 20,
              )
            ),
            if(unreadNotifications > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(minHeight: 16, minWidth: 16),
                  child: Text(
                    unreadNotifications > 99 ? "99+" : unreadNotifications.toString(),
                    style: TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        )
      );
    });
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.textTeriaryColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            if (_ignoreOnChange) return;        
            controller.onSearchChanged(value); 
          },
          style: const TextStyle(color: Colors.white, fontSize: 15),
          cursorColor: AppTheme.primaryColor,
          decoration: InputDecoration(
            hintText: "Search conversations",
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: Obx(() {
              final hasText = controller.searchQuery.isNotEmpty;
              return hasText
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _ignoreOnChange = true;
                    _searchController.text = '';
                    controller.clearSearch();
                    _ignoreOnChange = false;
                    FocusScope.of(context).unfocus();
                  },
                )
              : const SizedBox.shrink();
            }),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            Text(
              "No conversations found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                'No results for "${controller.searchQuery}"',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmptyStateIcons(),
            SizedBox(height: 24),
            _buildEmptyStateText(),
            SizedBox(height: 24),
            _buildEmptyStateActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateIcons() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('images/logo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildEmptyStateText() {
    return Column(
      children: [
        Text(
          'No conversation yet',
          style: TextStyle(
            color: AppTheme.secondaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Match someone you liked and start a conversation',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateActions() {
    return SizedBox(
      child: ElevatedButton.icon(
        onPressed: () {
          final mainController = Get.find<MainController>();
          mainController.changeTabIndex(2);
        },
        icon: Icon(Icons.search),
        label: Text('Start chatting'),
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: Colors.pinkAccent,
        ),
      ),
    );
  }
}