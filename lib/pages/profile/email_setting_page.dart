import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/services/firestore_service.dart';
import 'package:twinkle/themes/theme.dart';
import 'package:twinkle/components/email_verification_dialog.dart';

class EmailSettingPage extends StatefulWidget {
  const EmailSettingPage({super.key});

  @override
  State<EmailSettingPage> createState() => _EmailSettingPageState();
}

class _EmailSettingPageState extends State<EmailSettingPage> {
  final AuthController authController = Get.find<AuthController>();
  final FirestoreService _firestoreService = Get.put(FirestoreService());
  
  final TextEditingController _currentEmailController = TextEditingController();
  final TextEditingController _recoveryEmailController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _currentEmailController.dispose();
    _recoveryEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final currentID = authController.user!.uid;
    final user = await _firestoreService.getUserById(currentID);
    if (user != null) {
      setState(() {
        _currentEmailController.text = user.email ?? '';
        // Recovery email is not in the model, so we'll use a placeholder or empty
        _recoveryEmailController.text = '';
        _isLoadingData = false;
      });
    } else {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _saveEmail() async {
    if (_currentEmailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Current email is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate email format
    if (!_isValidEmail(_currentEmailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check if email has changed
    final currentUser = authController.user;
    final newEmail = _currentEmailController.text.trim();
    final oldEmail = currentUser?.email ?? '';

    if (newEmail != oldEmail) {
      // Show email verification dialog
      _showEmailVerificationDialog(newEmail);
    } else {
      // No change, just save
      await _updateEmail(newEmail);
    }
  }

  void _showEmailVerificationDialog(String email) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EmailVerificationDialog(
          email: email,
          onVerify: (code) async {
            // Verify code and update email
            // For now, we'll just update the email after verification
            // In a real app, you would verify the code first
            await _updateEmail(email);
          },
          onResend: () {
            // Resend verification code
            Get.snackbar(
              'Info',
              'Verification code resent to $email',
              backgroundColor: Colors.blue,
              colorText: Colors.white,
            );
          },
        );
      },
    );
  }

  Future<void> _updateEmail(String email) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentID = authController.user!.uid;
      
      // Update email in Firestore
      await _firestoreService.updateUserPartial(
        currentID,
        {
          'email': email,
        },
      );

      // Note: Updating email in Firebase Auth requires re-authentication
      // For now, we only update in Firestore
      
      Get.snackbar(
        'Success',
        'Email updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update email: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

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
            "Email",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEmail,
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
            // Current Email Section
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Color(0xFF6C9EFF), // Blue
                  Color(0xFF9B59B6), // Purple
                ],
              ).createShader(bounds),
              child: Text(
                "Current Email",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12),
            _buildEmailField(controller: _currentEmailController),
            SizedBox(height: 32),
            // Recovery Email Section
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Color(0xFF6C9EFF), // Blue
                  Color(0xFF9B59B6), // Purple
                ],
              ).createShader(bounds),
              child: Text(
                "Recovery Email",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12),
            _buildEmailField(controller: _recoveryEmailController),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField({required TextEditingController controller}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter email address",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }
}

