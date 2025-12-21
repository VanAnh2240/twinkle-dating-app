import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Main controller for managing user subscriptions and feature permissions
/// Handles all subscription-related logic including plan detection and feature access
class SubscriptionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reactive subscription state
  final Rx<String> currentPlanId = 'free'.obs;
  final Rx<DateTime?> expiresOn = Rx<DateTime?>(null);
  final RxBool isLoading = true.obs;

  // Swipe limits per plan
  static const Map<String, int> swipeLimits = {
    'free': 10,
    'plus': 50,
    'premium': -1, // -1 means unlimited
  };

  // Super likes limits per month
  static const Map<String, int> superLikesLimits = {
    'free': 0,
    'plus': 5,
    'premium': 10,
  };

  @override
  void onInit() {
    super.onInit();
    _initializeSubscriptionListener();
  }

  /// Check if user is on Free plan
  bool get isFree => currentPlanId.value == 'free';

  /// Check if user is on Plus plan
  bool get isPlus => currentPlanId.value == 'plus';

  /// Check if user is on Premium plan
  bool get isPremium => currentPlanId.value == 'premium';

  /// Check if user has any paid plan (Plus or Premium)
  bool get hasPaidPlan => isPlus || isPremium;

  /// Get current plan name
  String get currentPlanName {
    switch (currentPlanId.value) {
      case 'free':
        return 'Free';
      case 'plus':
        return 'Plus';
      case 'premium':
        return 'Premium';
      default:
        return 'Free';
    }
  }

  /// Initialize real-time listener for user's subscription
  void _initializeSubscriptionListener() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      isLoading.value = false;
      return;
    }

    // Listen to user's active subscription in real-time
    _firestore
        .collection('UserSubscriptions')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _updateSubscriptionState(snapshot.docs);
    });
  }

  /// Update subscription state based on Firestore data
  void _updateSubscriptionState(List<QueryDocumentSnapshot> docs) {
    isLoading.value = true;

    if (docs.isEmpty) {
      // No subscription record = Free user
      currentPlanId.value = 'free';
      expiresOn.value = null;
      isLoading.value = false;
      return;
    }

    // Find the most recent active subscription
    DateTime now = DateTime.now();
    String activePlan = 'free';
    DateTime? latestExpiry;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final planId = data['plan_id'] as String;
      final expiresTimestamp = data['expires_on'];
      
      DateTime expires;
      if (expiresTimestamp is Timestamp) {
        expires = expiresTimestamp.toDate();
      } else if (expiresTimestamp is int) {
        expires = DateTime.fromMillisecondsSinceEpoch(expiresTimestamp);
      } else {
        continue;
      }
      
      // Check if subscription is still active
      if (expires.isAfter(now)) {
        // If this is a newer subscription or first valid one found
        if (latestExpiry == null || expires.isAfter(latestExpiry)) {
          activePlan = planId;
          latestExpiry = expires;
        }
      }
    }

    currentPlanId.value = activePlan;
    expiresOn.value = latestExpiry;
    isLoading.value = false;
  }

  /// Reload subscription data manually
  Future<void> refreshSubscription() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    isLoading.value = true;

    try {
      final snapshot = await _firestore
          .collection('UserSubscriptions')
          .where('user_id', isEqualTo: userId)
          .get();

      _updateSubscriptionState(snapshot.docs);
    } catch (e) {
      print('Error refreshing subscription: $e');
      isLoading.value = false;
    }
  }

  /// Get swipe limit for current plan
  int getSwipeLimit() {
    return swipeLimits[currentPlanId.value] ?? 10;
  }

  /// Check if user has unlimited swipes
  bool hasUnlimitedSwipes() {
    return currentPlanId.value == 'premium';
  }

  /// Get super likes limit for current plan
  int getSuperLikesLimit() {
    return superLikesLimits[currentPlanId.value] ?? 0;
  }

  /// Check if user can see who likes them
  bool canSeeWhoLikesYou() {
    return isPlus || isPremium;
  }

  /// Check if user can see who super liked them
  bool canSeeWhoSuperLikedYou() {
    return isPlus || isPremium;
  }

  /// Check if user can see blocked/unblocked people
  bool canSeeBlockedUsers() {
    return isPremium;
  }

  /// Check if user has premium badge
  bool hasPremiumBadge() {
    return isPremium;
  }

  /// Check if user has priority support
  bool hasPrioritySupport() {
    return isPlus || isPremium;
  }

  /// Get formatted expiry date string (dd/MM/yyyy)
  String? getExpiryDateFormatted() {
    if (expiresOn.value == null) return null;
    final date = expiresOn.value!;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Get days remaining until expiry
  int? getDaysRemaining() {
    if (expiresOn.value == null) return null;
    if (currentPlanId.value == 'free') return null; // Free plan never expires
    
    final diff = expiresOn.value!.difference(DateTime.now());
    return diff.inDays;
  }

  /// Check if subscription is expiring soon (within 3 days)
  bool isExpiringSoon() {
    final days = getDaysRemaining();
    return days != null && days <= 3 && days > 0;
  }

  /// Check if subscription has expired
  bool isExpired() {
    if (expiresOn.value == null) return false;
    if (currentPlanId.value == 'free') return false;
    
    return expiresOn.value!.isBefore(DateTime.now());
  }

  /// Get subscription status message
  String getSubscriptionStatusMessage() {
    if (currentPlanId.value == 'free') {
      return 'You are using Free plan';
    }
    
    final days = getDaysRemaining();
    if (days == null) return '$currentPlanName Plan';
    
    if (days <= 0) {
      return '$currentPlanName Plan has expired';
    } else if (days <= 3) {
      return '$currentPlanName Plan - $days days left';
    } else {
      return '$currentPlanName Plan - Expires ${getExpiryDateFormatted()}';
    }
  }

  /// Get plan color for UI
  String getPlanColor() {
    switch (currentPlanId.value) {
      case 'plus':
        return '#FFD700'; // Gold
      case 'premium':
        return '#9C27B0'; // Purple
      default:
        return '#757575'; // Gray
    }
  }
}