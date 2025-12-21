import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaywallDialog extends StatelessWidget {
  final String title;
  final String message;
  final String feature;
  final String? requiredPlan; // 'plus' hoặc 'premium'
  
  const PaywallDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.feature,
    this.requiredPlan,
  }) : super(key: key);

  /// Show paywall dialog
  static Future<void> show({
    required String title,
    required String message,
    required String feature,
    String? requiredPlan,
  }) {
    return Get.dialog(
      PaywallDialog(
        title: title,
        message: message,
        feature: feature,
        requiredPlan: requiredPlan,
      ),
      barrierDismissible: true,
    );
  }

  /// Quick method for "See who likes you" feature
  static Future<void> showSeeWhoLikesYou() {
    return show(
      title: 'Premium Feature',
      message: 'Upgrade to Plus or Premium to see who likes you',
      feature: 'See who likes you',
      requiredPlan: 'plus',
    );
  }

  /// Quick method for unlimited swipes
  static Future<void> showUnlimitedSwipes() {
    return show(
      title: 'Swipe Limit Reached',
      message: 'Upgrade to Premium for unlimited swipes',
      feature: 'Unlimited swipes',
      requiredPlan: 'premium',
    );
  }

  /// Quick method for super likes
  static Future<void> showSuperLikes() {
    return show(
      title: 'Super Like Feature',
      message: 'Upgrade to Plus or Premium to send Super Likes',
      feature: 'Super Likes',
      requiredPlan: 'plus',
    );
  }

  /// Quick method for see blocked users
  static Future<void> showSeeBlockedUsers() {
    return show(
      title: 'Premium Feature',
      message: 'Only Premium members can see blocked and unblocked users',
      feature: 'See blocked users',
      requiredPlan: 'premium',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getPlanColor().withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _getPlanColor(),
                    _getPlanColor().withOpacity(0.7),
                  ],
                ),
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Feature badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _getPlanColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getPlanColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: _getPlanColor(),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    feature,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getPlanColor(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed('/subscription');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: _getPlanColor(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Upgrade now',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Maybe later',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPlanColor() {
    switch (requiredPlan) {
      case 'plus':
        return Colors.yellow; 
      case 'premium':
        return Colors.pinkAccent; 
      default:
        return Colors.blueAccent; 
    }
  }
}

extension PaywallExtension on GetInterface {
  Future<void> showPaywall({
    required String title,
    required String message,
    required String feature,
    String? requiredPlan,
  }) {
    return PaywallDialog.show(
      title: title,
      message: message,
      feature: feature,
      requiredPlan: requiredPlan,
    );
  }
}