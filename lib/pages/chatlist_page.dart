import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/components/chatting/chat_list.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/controllers/chatlist_controller.dart';
import 'package:twinkle/controllers/chat_controller.dart';
import 'package:twinkle/controllers/main_controller.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/themes/theme.dart';

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
                onRefresh: controller.refreshChats,
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
                          
                          return ChatListItem(
                            chat: chat,
                            otherUser: otherUser,
                            lastMessageTime: controller.formatLastMessageTime(chat.last_message_time),
                            onTap: () => controller.openChat(chat),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      }),
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
                  constraints: BoxConstraints(minHeight: 16, maxWidth: 16),
                  child: Text(
                    unreadNotifications > 99 ? "99+" : unreadNotifications.toString(),
                    style: TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
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