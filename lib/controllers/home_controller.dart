import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twinkle/controllers/subscription/subscriptions_controller.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/models/match_requests_model.dart';
import 'package:twinkle/pages/paywall_dialog_page.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/services/firestore_service.dart';
import 'package:twinkle/themes/theme.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable variables
  final RxList<UsersModel> allAvailableUsers = <UsersModel>[].obs;
  final RxList<UsersModel> displayedUsers = <UsersModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isFiltered = false.obs;
  
  // ✅ THÊM: Swipe counter
  final RxInt dailySwipeCount = 0.obs;
  
  // Filter options (temporary - chỉ apply khi user bấm Apply)
  final RxList<String> tempSelectedInterests = <String>[].obs;
  final RxList<String> tempSelectedValues = <String>[].obs;
  final RxDouble tempMaxDistance = 50.0.obs;
  final RxString tempSelectedGender = 'all'.obs;
  final RxInt tempMinAge = 18.obs;
  final RxInt tempMaxAge = 99.obs;

  // Applied filters (đã apply)
  final RxList<String> appliedInterests = <String>[].obs;
  final RxList<String> appliedValues = <String>[].obs;
  final RxDouble appliedMaxDistance = 50.0.obs;
  final RxString appliedGender = 'all'.obs;
  final RxInt appliedMinAge = 18.obs;
  final RxInt appliedMaxAge = 99.obs;

  // Subscription controller
  late SubscriptionController _subscriptionController;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _subscriptionController = Get.find<SubscriptionController>();
    _loadDailySwipeCount(); // ✅ Load swipe count
    loadUsersStream();
  }

  // ✅ THÊM: Load daily swipe count từ local storage
  Future<void> _loadDailySwipeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDate = prefs.getString('last_swipe_date_$currentUserId') ?? '';
      final today = DateTime.now().toString().substring(0, 10);
      
      // Nếu là ngày mới, reset về 0
      if (lastDate != today) {
        dailySwipeCount.value = 0;
        await prefs.setString('last_swipe_date_$currentUserId', today);
        await prefs.setInt('daily_swipe_count_$currentUserId', 0);
      } else {
        // Nếu cùng ngày, load count cũ
        dailySwipeCount.value = prefs.getInt('daily_swipe_count_$currentUserId') ?? 0;
      }
      
      print('📊 Loaded swipe count: ${dailySwipeCount.value}');
    } catch (e) {
      print('Error loading swipe count: $e');
      dailySwipeCount.value = 0;
    }
  }

  Future<void> _saveDailySwipeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toString().substring(0, 10);
      
      await prefs.setInt('daily_swipe_count_$currentUserId', dailySwipeCount.value);
      await prefs.setString('last_swipe_date_$currentUserId', today);
      
      print('Saved swipe count: ${dailySwipeCount.value}');
    } catch (e) {
      print('Error saving swipe count: $e');
    }
  }
  Future<void> resetDailySwipeCount() async {
    dailySwipeCount.value = 0;
    await _saveDailySwipeCount();
  }

  /// Apply subscription-based limits to displayed users
  void _applySubscriptionLimits() {
    if (displayedUsers.isEmpty) return;

    int limit;
    
    if (_subscriptionController.isFree) {
      limit = 10;
    } else if (_subscriptionController.isPlus) {
      limit = 50;
    } else if (_subscriptionController.isPremium) {
      return;
    } else {
      limit = 10;
    }

    if (displayedUsers.length > limit) {
      displayedUsers.value = displayedUsers.sublist(0, limit);
    }
  }

  // Load danh sách users từ Firestore với stream
  void loadUsersStream() {
    _firestoreService.getAllUsersStream().listen(
      (users) async {
        isLoading.value = true;
        
        try {
          // 1. Lọc bỏ current user
          List<UsersModel> filteredList = users
              .where((user) => user.user_id != currentUserId)
              .toList();
          
          // 2. Lấy danh sách blocked users
          final blockedUsers = await _firestoreService.getBlockedUsers(currentUserId);
          final blockedUserIds = <String>{};
          
          for (var block in blockedUsers) {
            blockedUserIds.add(block.blocked_user_id);
            blockedUserIds.add(block.user_id);
          }
          
          // 3. Lấy danh sách match requests (matched/unmatched)
          final matchRequests = await _getMatchRequestsOnce(currentUserId);
          final matchedOrUnmatchedUserIds = <String>{};
          
          for (var request in matchRequests) {
            if (request.status == MatchRequestsStatus.matched || 
                request.status == MatchRequestsStatus.unmatched) {
              matchedOrUnmatchedUserIds.add(request.sender_id);
              matchedOrUnmatchedUserIds.add(request.receiver_id);
            }
          }
          
          matchedOrUnmatchedUserIds.remove(currentUserId);
          
          // 4. Loại bỏ users bị block VÀ đã matched/unmatched
          final availableUsers = filteredList.where((user) {
            return !blockedUserIds.contains(user.user_id) && 
                   !matchedOrUnmatchedUserIds.contains(user.user_id);
          }).toList();

          allAvailableUsers.value = availableUsers;
          
          // 5. Nếu đang có filter, apply lại filter
          if (isFiltered.value) {
            await _applyCurrentFilters();
          } else {
            displayedUsers.value = List.from(allAvailableUsers);
          }
          _applySubscriptionLimits();
          
        } catch (e) {
          print('Error loading users: $e');
          _showErrorPopup('Failed to load users');
        } finally {
          isLoading.value = false;
        }
      },
      onError: (error) {
        isLoading.value = false;
        _showErrorPopup('Failed to load users');
      },
    );
  }

  // Helper: Lấy match requests một lần (không stream)
  Future<List<MatchRequestsModel>> _getMatchRequestsOnce(String userId) async {
    try {
      final snapshot = await _firestoreService.getMatchRequestsStream(userId).first;
      return snapshot;
    } catch (e) {
      print('Error getting match requests: $e');
      return [];
    }
  }

  Future<void> applyFilters() async {
    isLoading.value = true;
    
    try {
      appliedGender.value = tempSelectedGender.value;
      appliedMinAge.value = tempMinAge.value;
      appliedMaxAge.value = tempMaxAge.value;
      appliedInterests.value = List.from(tempSelectedInterests);
      appliedValues.value = List.from(tempSelectedValues);
      appliedMaxDistance.value = tempMaxDistance.value;
      
      isFiltered.value = true;
      
      await _applyCurrentFilters();
      
      // Apply subscription limits after filtering
      _applySubscriptionLimits();
      
      _showSuccessPopup(
        'Filters Applied',
        'Showing ${displayedUsers.length} users',
      );
      
    } catch (e) {
      print('Error applying filters: $e');
      _showErrorPopup('Failed to apply filters');
    } finally {
      isLoading.value = false;
    }
  }

  // Internal: Apply filters hiện tại
  Future<void> _applyCurrentFilters() async {
    List<UsersModel> result = List.from(allAvailableUsers);

    // Filter theo gender
    if (appliedGender.value != 'all') {
      result = result.where((user) => 
        user.gender.toLowerCase() == appliedGender.value.toLowerCase()
      ).toList();
    }

    // Filter theo age
    result = result.where((user) {
      if (user.date_of_birth == null) return false;
      final age = DateTime.now().difference(user.date_of_birth!).inDays ~/ 365;
      return age >= appliedMinAge.value && age <= appliedMaxAge.value;
    }).toList();

    // Filter theo interests, values
    if (appliedInterests.isNotEmpty || appliedValues.isNotEmpty) {
      List<UsersModel> finalResult = [];
      
      for (var user in result) {
        try {
          final profile = await _firestoreService.getUserProfile(user.user_id);
          if (profile == null) {
            finalResult.add(user);
            continue;
          }

          bool matchesFilter = true;

          // Filter theo interests
          if (appliedInterests.isNotEmpty) {
            final hasMatchingInterest = profile.interests.any(
              (interest) => appliedInterests.contains(interest)
            );
            if (!hasMatchingInterest) matchesFilter = false;
          }

          // Filter theo values
          if (appliedValues.isNotEmpty) {
            final hasMatchingValue = profile.values.any(
              (value) => appliedValues.contains(value)
            );
            if (!hasMatchingValue) matchesFilter = false;
          }

          if (matchesFilter) {
            finalResult.add(user);
          }
        } catch (e) {
          print('Error filtering user ${user.user_id}: $e');
          finalResult.add(user);
        }
      }
      
      result = finalResult;
    }

    displayedUsers.value = result;
    currentIndex.value = 0;
  }

  Future<bool> canSwipe() async {
    // Premium users have unlimited swipes
    if (_subscriptionController.isPremium) {
      return true;
    }

    // Get swipe limit based on subscription plan
    int swipeLimit;
    if (_subscriptionController.isFree) {
      swipeLimit = 10;
    } else if (_subscriptionController.isPlus) {
      swipeLimit = 50;
    } else {
      swipeLimit = 10; // Default to free
    }

    if (dailySwipeCount.value >= swipeLimit) {
      print('Swipe limit reached: ${dailySwipeCount.value}/$swipeLimit');
      
      // Show appropriate paywall
      if (_subscriptionController.isFree) {
        await PaywallDialog.show(
          title: 'Daily Swipe Limit Reached',
          message: 'You\'ve used all $swipeLimit swipes today.\n\nUpgrade to Plus for 50 swipes/day\nor Premium for unlimited swipes!',
          feature: 'More Swipes',
          requiredPlan: 'plus',
        );
      } else if (_subscriptionController.isPlus) {
        await PaywallDialog.showUnlimitedSwipes();
      }
      return false;
    }

    print('Can swipe: ${dailySwipeCount.value}/$swipeLimit');
    return true;
  }

  Future<void> swipeRight() async {
    if (displayedUsers.isEmpty || currentIndex.value >= displayedUsers.length) {
      return;
    }

    // Check if user can swipe
    if (!await canSwipe()) {
      return;
    }
    
    dailySwipeCount.value++;
    await _saveDailySwipeCount();
    print('Swiped right. Count: ${dailySwipeCount.value}');
    
    try {
      final targetUser = displayedUsers[currentIndex.value];
      
      await _firestoreService.requestOrCreateMatch(
        currentUserId,
        targetUser.user_id,
      );

      // Check if match was created
      final match = await _firestoreService.getMatches(
        currentUserId,
        targetUser.user_id,
      );
      
      if (match != null) {
        _showMatchDialog(targetUser);
      } else {
        _showLikePopup(targetUser.first_name);
      }
      
    } catch (e) {
      _showErrorPopup('Failed to like user');
    }
  }

  Future<void> swipeLeft() async {
    // Check if user can swipe
    if (!await canSwipe()) {
      return;
    }
    
    dailySwipeCount.value++;
    await _saveDailySwipeCount();
    print('👈 Swiped left. Count: ${dailySwipeCount.value}');
  }

  Future<void> swipeUp() async {
    if (displayedUsers.isEmpty || currentIndex.value >= displayedUsers.length) {
      return;
    }

    // Check if user has access to Super Like feature
    if (_subscriptionController.isFree) {
      await PaywallDialog.showSuperLikes();
      return;
    }

    // Check if user can swipe
    if (!await canSwipe()) {
      return;
    }
    
    dailySwipeCount.value++;
    await _saveDailySwipeCount();
    print('Super liked. Count: ${dailySwipeCount.value}');
    
    try {
      final targetUser = displayedUsers[currentIndex.value];
      
      await _firestoreService.requestOrCreateMatch(
        currentUserId,
        targetUser.user_id,
      );

      _showSuperLikePopup(targetUser.first_name);
      
    } catch (e) {
      _showErrorPopup('Failed to super like');
    }
  }
  
  // Show match dialog
  void _showMatchDialog(UsersModel matchedUser) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.pink.shade400,
                Colors.purple.shade400,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                "It's a Match!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You and ${matchedUser.first_name} liked each other',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMatchAvatar(_auth.currentUser?.photoURL ?? ''),
                  Icon(Icons.favorite, color: Colors.white, size: 40),
                  _buildMatchAvatar(matchedUser.profile_picture),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  List<String> userIDs = [currentUserId, matchedUser.user_id];
                  userIDs.sort();
                  String chatID = '${userIDs[0]}_${userIDs[1]}';
                  Get.back();
                  Get.toNamed(AppRoutes.chat, arguments: {
                    'chat_id': chatID,
                    'other_user': matchedUser
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Send Message',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Keep Swiping',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildMatchAvatar(String imageUrl) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        image: imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
        color: imageUrl.isEmpty ? Colors.grey : null,
      ),
      child: imageUrl.isEmpty
          ? Icon(Icons.person, size: 40, color: Colors.white)
          : null,
    );
  }

  void _showLikePopup(String userName) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.quaternaryColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Liked!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You liked $userName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: AppTheme.quaternaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
    
    // Auto close after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isDialogOpen ?? false) Get.back();
    });
  }

  void _showSuperLikePopup(String userName) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFD700),
                const Color(0xFFFFA500),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Super Like!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You super liked $userName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFFA500),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
    
    // Auto close after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isDialogOpen ?? false) Get.back();
    });
  }

  void _showSuccessPopup(String title, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
    
    // Auto close after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isDialogOpen ?? false) Get.back();
    });
  }

  void _showErrorPopup(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Error',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void updateTempInterestFilter(List<String> interests) {
    tempSelectedInterests.value = interests;
  }

  void updateTempValueFilter(List<String> values) {
    tempSelectedValues.value = values;
  }

  void updateTempGenderFilter(String gender) {
    tempSelectedGender.value = gender;
  }

  void updateTempAgeFilter(int min, int max) {
    tempMinAge.value = min;
    tempMaxAge.value = max;
  }

  void updateTempDistanceFilter(double distance) {
    tempMaxDistance.value = distance;
  }

  // Reset filters - load lại toàn bộ users
  void resetFilters() {
    // Reset temp filters
    tempSelectedInterests.clear();
    tempSelectedValues.clear();
    tempSelectedGender.value = 'all';
    tempMinAge.value = 18;
    tempMaxAge.value = 99;
    tempMaxDistance.value = 50.0;
    
    // Reset applied filters
    appliedInterests.clear();
    appliedValues.clear();
    appliedGender.value = 'all';
    appliedMinAge.value = 18;
    appliedMaxAge.value = 99;
    appliedMaxDistance.value = 50.0;
    
    // Set flag
    isFiltered.value = false;
    
    // Hiển thị lại tất cả users
    displayedUsers.value = List.from(allAvailableUsers);
    
    // Apply subscription limits
    _applySubscriptionLimits();
    
    currentIndex.value = 0;
  }

  Future<void> refresh() async {
    isLoading.value = true;
    currentIndex.value = 0;
    
    try {
      await Future.delayed(Duration(milliseconds: 500));
      
      // Giữ nguyên filter state
      if (isFiltered.value) {
        await _applyCurrentFilters();
      } else {
        displayedUsers.value = List.from(allAvailableUsers);
      }

      // Apply subscription limits
      _applySubscriptionLimits();
    } catch (e) {
      print('Error refreshing: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get current user being displayed
  UsersModel? get currentUser {
    if (displayedUsers.isEmpty || currentIndex.value >= displayedUsers.length) {
      return null;
    }
    return displayedUsers[currentIndex.value];
  }
  
  /// Block current user being viewed
  Future<void> blockCurrentUser() async {
    final user = currentUser;
    if (user == null) {
      _showErrorPopup('No user to block');
      return;
    }

    try {
      // Show loading
      Get.dialog(
        Center(child: CircularProgressIndicator(
          color: Colors.white)),
          barrierDismissible: false,
          );
        await _firestoreService.blockUser(
          currentUserId,
          user.user_id,
        );
      Get.back();
      displayedUsers.removeAt(currentIndex.value);
      allAvailableUsers.removeWhere((u) => u.user_id == user.user_id);
      if (currentIndex.value >= displayedUsers.length && displayedUsers.isNotEmpty) {
        currentIndex.value = displayedUsers.length - 1;
      }

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Blocked',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${user.first_name} has been blocked',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (Get.isDialogOpen ?? false) Get.back();
      });
  
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      
      print('Error blocking user: $e');
      _showErrorPopup('Failed to block user');
    }
  }

  @override
    void onClose() {
    super.onClose();
  }
}