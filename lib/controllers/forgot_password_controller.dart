import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _emailSent = false.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get emailSent => _emailSent.value;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendPasswordResetEmail() async {
    if (!formKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;
      _error.value = '';

      await _authService.sendPasswordResetEmail(emailController.text.trim());
      _emailSent.value = true;

      await Future.delayed(const Duration(seconds: 2));
      Get.snackbar(
        'Success',
        'Password reset link sent to email ${emailController.text}',
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to send reset email: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void goback() {
    Get.back();
  }

  void resendEmail() {
    _emailSent.value = false;
    sendPasswordResetEmail();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  void clearError() {
    _error.value = '';
  }
}
