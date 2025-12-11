import 'package:firebase_auth/firebase_auth.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:twinkle/services/user_service.dart';


class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<User?> _user = Rx<User?>(null);
  final Rx<UsersModel?> _usersModel = Rx<UsersModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isinitialized = false.obs;
  User? get user => _user.value;
  UsersModel? get userModel => _usersModel.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isAuthenticated => _user.value != null;
  bool get isinitialized => _isinitialized.value;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_authService.authStateChanges);
    ever(_user, _handleaAuthStateChange);
  }

  Future<void> _handleaAuthStateChange(User? user) async {
    if (user == null) {
      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      _usersModel.value = await UserService().getUserById(user.uid);

      if (Get.currentRoute != AppRoutes.home) {
        Get.offAllNamed(AppRoutes.home);
      }
    }
    if (!_isinitialized.value) {
      _isinitialized.value = true;
    }
  }

  void checkInitializedAuthState() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user.value = currentUser;
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
    _isinitialized.value = true;
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      UsersModel? usersModel = await _authService.signInWithEmailPassword(email, password);
      if (usersModel != null) {
        _usersModel.value = usersModel;
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', "Failed to login");
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> registerWithEmailPassword(String email, String password) async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      final usersModel = await _authService.registerWithEmailPassword(email, password);
      _usersModel.value = usersModel;
      
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', "Failed to create account");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      await _authService.signOut();
      _usersModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', "Failed to sign out");
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading.value = true;
      await _authService.deleteAccount();
      _usersModel.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', "Failed to delete account");
      print(e);
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = '';
  }

}
