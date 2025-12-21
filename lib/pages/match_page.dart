import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/match_controller.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/services/profile_service.dart';
import 'package:twinkle/models/profile_model.dart';

class MatchPage extends StatefulWidget {
  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  final MatchController controller = Get.put(MatchController());
  final ProfileService _profileService = ProfileService();
  
  // Cache profiles để tránh load lại nhiều lần
  final Map<String, ProfileModel?> _profileCache = {};

  // Lấy profile từ cache hoặc load mới
  Future<ProfileModel?> _getProfile(String userId) async {
    if (_profileCache.containsKey(userId)) {
      return _profileCache[userId];
    }

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
  Widget _buildAvatar(UsersModel user, {double size = 70}) {
    return FutureBuilder<ProfileModel?>(
      future: _getProfile(user.user_id),
      builder: (context, snapshot) {
        // Nếu đang load
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[800],
            ),
            child: Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.pinkAccent,
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

        return _buildAvatarImage(avatarUrl, user, size);
      },
    );
  }

  // Widget xử lý hiển thị ảnh (Network hoặc File)
  Widget _buildAvatarImage(String? avatarUrl, UsersModel user, double size) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return _getDefaultAvatar(user, size);
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
                color: Colors.pinkAccent,
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
          return _getDefaultAvatar(user, size);
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
            return _getDefaultAvatar(user, size);
          },
        );
      } else {
        return _getDefaultAvatar(user, size);
      }
    } catch (e) {
      print('Error accessing file: $e');
      return _getDefaultAvatar(user, size);
    }
  }

  /// Widget mặc định khi không có ảnh profile
  Widget _getDefaultAvatar(UsersModel user, double size) {
    final colors = [
      Colors.pinkAccent,
      Colors.purpleAccent,
      Colors.blueAccent,
      Colors.tealAccent,
      Colors.orangeAccent,
    ];

    final colorIndex = user.user_id.hashCode % colors.length;
    final color = colors[colorIndex.abs()];

    return Container(
      color: color.withOpacity(0.3),
      child: Center(
        child: Text(
          user.first_name.isNotEmpty ? user.first_name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      floatingActionButton: _buildSearchButton(),
      body: Obx(() {
        if (controller.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.pinkAccent),
                SizedBox(height: 16),
                Text(
                  'Loading matches...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        if (controller.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                SizedBox(height: 16),
                Text(
                  'Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    controller.error,
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.refreshMatches(),
                  icon: Icon(Icons.refresh),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        final matches = controller.filteredMatches;
        final isSearching = controller.isSearchOpen.value && controller.searchQuery.isNotEmpty;

        if (controller.matches.isEmpty) {
          return _buildEmptyState();
        }

        if (matches.isEmpty && isSearching) {
          return Column(
            children: [
              _buildSearchBar(),
              Expanded(child: _buildNoSearchResults()),
            ],
          );
        }

        return Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _profileCache.clear(); // Clear cache on refresh
                  await controller.refreshMatches();
                },
                backgroundColor: Colors.grey[900],
                color: Colors.pinkAccent,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: matches.length,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: _buildMatchCard(matches[index], index),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: Text('Matches',
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
      actions: [
        Obx(() => Container(
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${controller.filteredMatches.length}',
                  style: TextStyle(
                      color: Colors.pinkAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            )),
      ],
    );
  }

  Widget _buildSearchButton() {
    return Obx(() => FloatingActionButton(
          onPressed: controller.toggleSearch,
          backgroundColor: Colors.pinkAccent,
          elevation: 4,
          child: Icon(controller.isSearchOpen.value ? Icons.close : Icons.search,
              color: Colors.white),
        ));
  }

  Widget _buildSearchBar() {
    return Obx(() => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: controller.isSearchOpen.value ? 60 : 0,
          child: controller.isSearchOpen.value
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
                  ),
                  child: TextField(
                    autofocus: true,
                    onChanged: controller.updateSearchQuery,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Icon(Icons.search, color: Colors.pinkAccent),
                      suffixIcon: controller.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.white54),
                              onPressed: controller.clearSearch)
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ));
  }

  Widget _buildMatchCard(UsersModel user, int index) {
    final gradients = [
      [Color(0xFFFF6B9D), Color(0xFFC44569)],
      [Color(0xFF4A90E2), Color(0xFF357ABD)],
      [Color(0xFFFF8C42), Color(0xFFE8743B)],
      [Color(0xFF9B59B6), Color(0xFF8E44AD)],
      [Color(0xFF1ABC9C), Color(0xFF16A085)],
    ];

    final gradient = gradients[index % gradients.length];

    return GestureDetector(
      onTap: () => controller.startChat(user),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: gradient[0].withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6))
          ],
        ),
        child: Stack(
          children: [
            Positioned(
                top: -30,
                right: -30,
                child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)))),
            Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: 'match_avatar_${user.user_id}',
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          child: ClipOval(child: _buildAvatar(user)),
                        ),
                      ),
                      if (user.is_online)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${user.first_name} ${user.last_name}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(user.is_online ? Icons.circle : Icons.access_time,
                                size: 14, color: Colors.white70),
                            SizedBox(width: 4),
                            Expanded(
                                child: Text(controller.getLastSeenText(user),
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            _buildActionButton(
                                icon: Icons.chat_bubble_outline,
                                label: 'Message',
                                onTap: () => controller.startChat(user)),
                            SizedBox(width: 8),
                            _buildActionButton(
                                icon: Icons.more_horiz,
                                label: '',
                                onTap: () => _showOptionsMenu(user)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: label.isEmpty ? 10 : 12, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            if (label.isNotEmpty) ...[
              SizedBox(width: 4),
              Text(label,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.white24),
          SizedBox(height: 16),
          Text('No matches found',
              style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Try searching with a different name',
              style: TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  void _showOptionsMenu(UsersModel user) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
            SizedBox(height: 24),
            _buildUserHeader(user),
            SizedBox(height: 20),
            Divider(color: Colors.grey[800], height: 1),
            _buildOption(
                Icons.heart_broken,
                'Unmatch',
                "You won't see each other anymore",
                Colors.red,
                () => _confirmAction('Unmatch',
                    "You guys won't be able to see or text each other again!", Colors.red,
                    () => controller.unMatch(user))),
            Divider(color: Colors.grey[800], height: 1),
            _buildOption(
                Icons.block,
                'Block',
                "They won't be able to contact you",
                Colors.orange,
                () => _confirmAction('Block',
                    "This person won't be able to see or text you again!", Colors.orange,
                    () => controller.blockMatch(user))),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(UsersModel user) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                shape: BoxShape.circle, border: Border.all(color: Colors.grey[700]!, width: 2)),
            child: ClipOval(child: _buildAvatar(user, size: 50)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${user.first_name} ${user.last_name}',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(controller.getLastSeenText(user),
                    style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
      IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Get.back();
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }

  void _confirmAction(String action, String message, Color color, VoidCallback onConfirm) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration:
              BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$action?',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 15)),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(action,
                      style:
                          TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey[700]!, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text('Cancel',
                      style:
                          TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        _profileCache.clear();
        await controller.refreshMatches();
      },
      backgroundColor: Colors.grey[900],
      color: Colors.pinkAccent,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: Get.height * 0.7,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [
                        Colors.pinkAccent.withOpacity(0.3),
                        Colors.purpleAccent.withOpacity(0.3)
                      ]),
                    ),
                    child: Icon(Icons.favorite_border, size: 70, color: Colors.pinkAccent),
                  ),
                  SizedBox(height: 32),
                  Text('No matches yet',
                      style:
                          TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text('Start swiping to find your perfect match!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Pull down to refresh',
                      style: TextStyle(color: Colors.white38, fontSize: 14, fontStyle: FontStyle.italic)),
                  SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Get.offAllNamed(AppRoutes.main),
                    icon: Icon(Icons.explore, size: 24),
                    label: Text('Start Exploring',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}