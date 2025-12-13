import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/models/users_model.dart';
import 'package:twinkle/services/firestore_service.dart';

class UserController extends GetxController {
  final FirestoreService _user = Get.find<FirestoreService>();
  final AuthController _auth = Get.find<AuthController>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxBool _isLoading = false.obs;
  final RxBool _isEditing = false.obs;
  final RxString _error = ''.obs;
  final Rx<UsersModel?> _currentUser = Rx<UsersModel?>(null);

  bool get isLoading => _isLoading.value;
  bool get isEditing => _isEditing.value;
  String get error => _error.value;
  UsersModel? get currentUser => _currentUser.value;

  @override
  void onInit(){
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose(){
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.onClose();
  }
  
  void _loadUserData() {
    final currentUserId = _auth.user?.uid;

    if (currentUserId != null) {
      _currentUser.bindStream(_user.getUserStream(currentUserId));

      ever(_currentUser, (UsersModel? user) {
        if (user != null) {
          firstNameController.text = user.first_name!;
          lastNameController.text = user.last_name!;
          emailController.text = user.email;
        }
      });
    }
  }

  void toggleEditing() {
    _isEditing.value = !_isEditing.value;

    if(!_isEditing.value) {
      final user = _currentUser.value;
      if (user != null) {
          firstNameController.text = user.first_name!;
          lastNameController.text = user.last_name!;
          emailController.text = user.email;
      }
    }
  }
}
