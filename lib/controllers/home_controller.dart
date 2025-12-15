import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/models/profile_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/models/match_requests_model.dart';
import 'package:twinkle/models/blocked_users_model.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/services/firestore_service.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable variables
  final RxList<UsersModel> allAvailableUsers = <UsersModel>[].obs; // Users sau khi loại trừ blocked/matched
  final RxList<UsersModel> displayedUsers = <UsersModel>[].obs; // Users đang hiển thị (có thể đã filter)
  final RxBool isLoading = true.obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isFiltered = false.obs; // Flag để biết có đang apply filter không
  
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

  String get currentUserId => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    loadUsersStream();
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
              // Thêm cả sender và receiver
              matchedOrUnmatchedUserIds.add(request.sender_id);
              matchedOrUnmatchedUserIds.add(request.receiver_id);
            }
          }
          
          // Loại bỏ current user khỏi set
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
            // Nếu không filter, hiển thị tất cả
            displayedUsers.value = List.from(allAvailableUsers);
          }
          
        } catch (e) {
          print('Error loading users: $e');
          Get.snackbar(
            'Error',
            'Failed to load users: $e',
          );
        } finally {
          isLoading.value = false;
        }
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to load users: $error',
        );
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

  // Apply filters khi user bấm Apply trong dialog
  Future<void> applyFilters() async {
    isLoading.value = true;
    
    try {
      // Copy temp filters to applied filters
      appliedGender.value = tempSelectedGender.value;
      appliedMinAge.value = tempMinAge.value;
      appliedMaxAge.value = tempMaxAge.value;
      appliedInterests.value = List.from(tempSelectedInterests);
      appliedValues.value = List.from(tempSelectedValues);
      appliedMaxDistance.value = tempMaxDistance.value;
      
      isFiltered.value = true;
      
      await _applyCurrentFilters();
      
    } catch (e) {
      print('Error applying filters: $e');
      Get.snackbar(
        'Error',
        'Failed to apply filters',
      );
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

    // Filter theo interests, values (cần load profile)
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
  }

  // Swipe Right - Like user
  Future<void> swipeRight() async {
    if (displayedUsers.isEmpty || currentIndex.value >= displayedUsers.length) {
      return;}
    
    try {
      final targetUser = displayedUsers[currentIndex.value];
      
      // Request or create match
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
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to like user: $e',
      );
    }
  }

  // Swipe Left - Pass user
  Future<void> swipeLeft() async {
  }

  // Swipe Up - Super like
  Future<void> swipeUp() async {
    if (displayedUsers.isEmpty || currentIndex.value >= displayedUsers.length) {
      return;
    }
    
    try {
      final targetUser = displayedUsers[currentIndex.value];
      
      await _firestoreService.requestOrCreateMatch(
        currentUserId,
        targetUser.user_id,
      );

      Get.snackbar(
        'Super Like!',
        'You super liked ${targetUser.first_name}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
        duration: Duration(seconds: 2),
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to super like: $e',
      );
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
                  Get.toNamed(AppRoutes.chat, arguments: {'chat_id': chatID, 'other_user': matchedUser});
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

  // Navigate to user profile detail
  void viewUserProfile(UsersModel user) {
    Get.toNamed('/profile-detail', arguments: user);
  }

  // Update temp filters (trong dialog, chưa apply)
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
    currentIndex.value = 0;
    
    Get.snackbar(
      'Filters Reset',
      'Showing all available users',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  Future<void> refresh() async {
    isLoading.value = true;
    currentIndex.value = 0;
    
    isFiltered.value = false;
    
    await Future.delayed(Duration(milliseconds: 500));
    
    displayedUsers.value = List.from(allAvailableUsers);
    
    isLoading.value = false;
  }

  // Get current user being displayed
  UsersModel? get currentUser {
    if (displayedUsers.isEmpty || currentIndex.value >= displayedUsers.length) {
      return null;
    }
    return displayedUsers[currentIndex.value];
  }

  @override
  void onClose() {
    super.onClose();
  }
}