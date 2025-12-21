import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/routes/app_routes.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

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
            "Privacy & Security",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Login & Recovery Section
            _buildSection(
              title: "Login & Recovery",
              description:
                  "Manage your password, login options, and recovery methods.",
              items: [
                _buildSecurityItem(
                  title: "Change Password",
                  onTap: () {
                    Get.toNamed(AppRoutes.changePassword);
                  },
                ),
                _buildSecurityItem(
                  title: "Two-Factor Authentication (2FA)",
                  onTap: () {
                    // TODO: Navigate to 2FA page
                  },
                ),
              ],
            ),
            SizedBox(height: 32),
            // Security Checkup Section
            _buildSection(
              title: "Security Checkup",
              description:
                  "Review security issues by running a checkup on apps, devices, and sent emails.",
              items: [
                _buildSecurityItem(
                  title: "Places You've Logged In",
                  onTap: () {
                    // TODO: Navigate to login history page
                  },
                ),
                _buildSecurityItem(
                  title: "Login Alert",
                  onTap: () {
                    // TODO: Navigate to login alert page
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF9B59B6), // Purple color
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildSecurityItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

