import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/firestore_service.dart';

class MatchController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  // State
  final RxList<UsersModel> users = <UsersModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  String? get currentUserID => _authController.user?.uid;

  @override
  void onInit() {
    super.onInit();
    _loadAllUsers();
  }

  /// Load toàn bộ user từ Firestore
  void _loadAllUsers() {
    if (currentUserID == null) return;

    isLoading.value = true;

    _firestoreService.getAllUsersStream().listen(
      (list) {
        users.assignAll(
          list.where((u) => u.user_id != currentUserID),
        );
        isLoading.value = false;
      },
      onError: (e) {
        error.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  /// Swipe right → request hoặc auto match
  Future<void> swipeRight(String targetUserID) async {
    if (currentUserID == null) return;

    try {
      await _firestoreService.requestOrCreateMatch(
        currentUserID!,
        targetUserID,
      );
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// Swipe left → hiện tại không làm gì
  void swipeLeft(String targetUserID) {
    // Có thể log hoặc bỏ qua
  }
}
