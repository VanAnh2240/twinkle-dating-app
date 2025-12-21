import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/main_controller.dart';
import 'package:twinkle/controllers/subscription/subscriptions_controller.dart';
import 'package:twinkle/pages/paywall_dialog_page.dart';
import 'package:twinkle/routes/app_routes.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionController = Get.find<SubscriptionController>();
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Color(0xFF6C9EFF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            _buildSettingItem(
              icon: Icons.person_outline,
              title: "Account",
              onTap: () => Get.toNamed(AppRoutes.account),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              onTap: () => Get.toNamed(AppRoutes.notification),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: "Privacy & Security",
              onTap: () => Get.toNamed(AppRoutes.privacySecurity),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final isPremium = subscriptionController.isPremium;
              return _buildSettingItem(
                icon: Icons.block_rounded,
                title: "Block list",
                isPremium: !isPremium,
                onTap: () {
                  if (isPremium) {
                    Get.toNamed(AppRoutes.blockList);
                  } else {
                    PaywallDialog.showSeeBlockedUsers();
                  }
                },
              );
            }),
            const SizedBox(height: 16),
            Obx(() {
              final isPremium = subscriptionController.isPremium;
              if (!isPremium) {
                return _buildPremiumItem();
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isPremium) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF39C12),
                            Colors.pinkAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.workspace_premium,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumItem() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.back();
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.find<MainController>().changeTabIndex(4);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 107, 230),
              Color.fromARGB(255, 198, 106, 234),
              Color.fromARGB(255, 52, 91, 219),
              Color.fromARGB(255, 204, 128, 46),
              Color(0xFFF39C12),
            ],
          ),
        ),
        child: Row(
          children: const [
            Icon(Icons.workspace_premium, color: Colors.white, size: 20),
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