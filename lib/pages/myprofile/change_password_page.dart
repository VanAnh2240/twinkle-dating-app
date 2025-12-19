import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/services/auth_service.dart';
import 'package:twinkle/themes/theme.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final AuthController authController = Get.find<AuthController>();
  final AuthService _authService = AuthService();
  
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showRepeatPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  bool _validatePassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[a-zA-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*]'))) return false;
    return true;
  }

  bool get _isPasswordValid => _validatePassword(_newPasswordController.text);
  bool get _isPasswordMatch => 
      _newPasswordController.text == _repeatPasswordController.text && 
      _repeatPasswordController.text.isNotEmpty;

  Future<void> _savePassword() async {
    if (_currentPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your current password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!_isPasswordValid) {
      Get.snackbar(
        'Error',
        'New password does not meet requirements',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!_isPasswordMatch) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      
      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Success!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your password has been updated successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.back();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change password: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Color(0xFF6C9EFF), // Blue
              Color(0xFF9B59B6), // Purple
            ],
          ).createShader(bounds),
          child: Text(
            "Change Password",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePassword,
            child: Text(
              "Save",
              style: TextStyle(
                color: _isLoading ? Colors.grey : AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Password
            _buildPasswordField(
              label: "Current Password",
              controller: _currentPasswordController,
              showPassword: _showCurrentPassword,
              onToggleVisibility: () {
                setState(() {
                  _showCurrentPassword = !_showCurrentPassword;
                });
              },
            ),
            SizedBox(height: 24),
            // New Password
            _buildPasswordField(
              label: "New Password",
              controller: _newPasswordController,
              showPassword: _showNewPassword,
              onToggleVisibility: () {
                setState(() {
                  _showNewPassword = !_showNewPassword;
                });
              },
            ),
            SizedBox(height: 16),
            // Password Requirements
            if (_newPasswordController.text.isNotEmpty) ...[
              _buildRequirement(
                text: "Must be at least 8 characters long",
                isValid: _newPasswordController.text.length >= 8,
              ),
              SizedBox(height: 8),
              _buildRequirement(
                text: "Include at least 1 letter and 1 number",
                isValid: _newPasswordController.text.contains(RegExp(r'[a-zA-Z]')) &&
                         _newPasswordController.text.contains(RegExp(r'[0-9]')),
              ),
              SizedBox(height: 8),
              _buildRequirement(
                text: "Contain at least one upper letter (A-Z)",
                isValid: _newPasswordController.text.contains(RegExp(r'[A-Z]')),
              ),
              SizedBox(height: 8),
              _buildRequirement(
                text: "Contain at least one special character (e.g., !@#\$%^&*)",
                isValid: _newPasswordController.text.contains(RegExp(r'[!@#$%^&*]')),
              ),
              SizedBox(height: 24),
            ],
            // Repeat Password
            _buildPasswordField(
              label: "Repeat Password",
              controller: _repeatPasswordController,
              showPassword: _showRepeatPassword,
              onToggleVisibility: () {
                setState(() {
                  _showRepeatPassword = !_showRepeatPassword;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !showPassword,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildRequirement({
    required String text,
    required bool isValid,
  }) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 20,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.white : Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

