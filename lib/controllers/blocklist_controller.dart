import 'package:get/get.dart';
import 'package:twinkle/models/blocked_users_model.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/auth_service.dart';
import 'package:twinkle/services/firestore_service.dart';

class BlockListController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = Get.find<AuthService>();
  
  // Observable lists
  var blockedUserProfiles = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  
  // Current user ID
  String get currentUserId => _authService.currentUserId ?? '';
  
  @override
  void onInit() {
    super.onInit();
    fetchBlockedUsers();
  }

  /// Lấy danh sách người dùng đã block
  Future<void> fetchBlockedUsers() async {
    try {
      isLoading.value = true;
      
      // Lấy danh sách blocked users
      List<BlockedUsersModel> blockedUsers = 
          await _firestoreService.getBlockedUsers(currentUserId);

      List<Map<String, dynamic>> userProfiles = [];

      for (var blockedUser in blockedUsers) {
        // Chỉ lấy người dùng mà current user đã block (không lấy người block mình)
        if (blockedUser.user_id != currentUserId) continue;

        try {
          // Lấy thông tin chi tiết của người dùng bị block
          UsersModel user = await _firestoreService.getUserById(
            blockedUser.blocked_user_id
          );

          userProfiles.add({
            'block_id': blockedUser.block_id,
            'blocked_user_id': blockedUser.blocked_user_id,
            'blocked_on': blockedUser.blocked_on,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'full_name': '${user.first_name} ${user.last_name}'.trim(),
            'email': user.email,
            'profile_picture': user.profile_picture,
            'gender': user.gender,
            'is_online': user.is_online,
            'last_seen': user.last_seen,
          });
        } catch (e) {
          print('Error loading user ${blockedUser.blocked_user_id}: $e');
          // Nếu không load được user, vẫn thêm với thông tin cơ bản
          userProfiles.add({
            'block_id': blockedUser.block_id,
            'blocked_user_id': blockedUser.blocked_user_id,
            'blocked_on': blockedUser.blocked_on,
            'first_name': 'Unknown',
            'last_name': 'User',
            'full_name': 'Unknown User',
            'email': '',
            'profile_picture': '',
            'gender': '',
            'is_online': false,
            'last_seen': DateTime.now(),
          });
        }
      }

      // Sắp xếp theo thời gian block (mới nhất trước)
      userProfiles.sort((a, b) => 
        (b['blocked_on'] as DateTime).compareTo(a['blocked_on'] as DateTime)
      );

      blockedUserProfiles.value = userProfiles;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load blocked users: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error in fetchBlockedUsers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Unblock user
  Future<void> unblockUser(String blockedUserId) async {
    try {
      await _firestoreService.unBlockUser(currentUserId, blockedUserId);
      
      // Refresh list
      await fetchBlockedUsers();
      
      Get.snackbar(
        'Success',
        'User unblocked successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to unblock user: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error in unblockUser: $e');
    }
  }

  /// Refresh blocked list (pull to refresh)
  Future<void> refreshBlockedList() async {
    await fetchBlockedUsers();
  }

  /// Get blocked count
  int blockedCount() {
    return blockedUserProfiles.length;
  }
}