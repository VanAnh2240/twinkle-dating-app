import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/routes/app_routes.dart';
import 'package:twinkle/themes/theme.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

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
        title: Text(
          "Settings",
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
            _buildSettingItem(
              icon: Icons.person_outline,
              title: "Account",
              onTap: () => Get.toNamed(AppRoutes.account),
            ),
            SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              onTap: () => Get.toNamed(AppRoutes.notification),
            ),
            SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: "Privacy & Security",
              onTap: () => Get.toNamed(AppRoutes.privacySecurity),
            ),
            SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.language_outlined,
              title: "Languages & Interfaces",
              onTap: () {
                // TODO: Navigate to languages page
              },
            ),
            SizedBox(height: 16),
            _buildPremiumItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumItem() {
    return InkWell(
      onTap: () {
        // TODO: Navigate to premium page
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 2,
            color: Colors.transparent,
          ),
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF6B9D), // Pink
              Color(0xFF9B59B6), // Purple
              Color(0xFF3498DB), // Blue
              Color(0xFF2ECC71), // Green
              Color(0xFFF39C12), // Orange/Yellow
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(Icons.workspace_premium, color: Colors.white, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                "Premium",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}