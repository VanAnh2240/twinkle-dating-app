import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/auth_controller.dart';
import 'package:twinkle/services/firestore_service.dart';
import 'package:twinkle/themes/theme.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:intl/intl.dart';

class AccountPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final FirestoreService _firestoreService = Get.put(FirestoreService());

  AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentID = authController.user!.uid;

    return FutureBuilder(
      future: _firestoreService.getUserById(currentID),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        final user = snapshot.data!;

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
            title: Text(
              "Account",
              style: TextStyle(
                color: Color(0xFF6C9EFF), // Light blue color
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Profile Picture
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: user.profile_picture != null &&
                            user.profile_picture!.isNotEmpty
                        ? NetworkImage(user.profile_picture!)
                        : null,
                    child: (user.profile_picture == null ||
                            user.profile_picture.isEmpty)
                        ? Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                // Name
                Text(
                  "${user.first_name ?? ''} ${user.last_name ?? ''}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),
                // Account Details
                _buildAccountField(
                  label: "Name",
                  value: "${user.first_name ?? ''} ${user.last_name ?? ''}",
                  onTap: () {
                    Get.toNamed(AppRoutes.nameSetting);
                  },
                ),
                SizedBox(height: 12),
                _buildAccountField(
                  label: "Birthday",
                  value: user.date_of_birth != null
                      ? DateFormat('dd/MM/yyyy').format(user.date_of_birth!)
                      : "Not set",
                  onTap: () {
                    Get.toNamed(AppRoutes.birthdaySetting);
                  },
                ),
                SizedBox(height: 12),
                _buildAccountField(
                  label: "Email",
                  value: user.email ?? "Not set",
                  onTap: () {
                    Get.toNamed(AppRoutes.emailSetting);
                  },
                ),
                SizedBox(height: 12),
                _buildAccountField(
                  label: "Phone Number",
                  value: "09* **** *99", // Placeholder - phone number not in model
                  onTap: () {
                    // TODO: Navigate to edit phone page
                  },
                ),
                SizedBox(height: 32),
                // Log Out Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "LOG OUT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  "Confirm Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                // Question
                Text(
                  "Do you really want to log out of your account?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    // Log Out Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          authController.signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF6B4A), // Red-orange
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Log Out",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Cancel Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

