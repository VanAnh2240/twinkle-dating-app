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

  // Reactive plan flags
  RxBool get isFree => (currentPlanId.value == 'free').obs;
  RxBool get isPlus => (currentPlanId.value == 'plus').obs;
  RxBool get isPremium => (currentPlanId.value == 'premium').obs;

  // Swipe limits per plan
  static const Map<String, int> swipeLimits = {
    'free': 10,
    'plus': 50,
    'premium': -1, // -1 means unlimited
  };

  @override
  void onInit() {
    super.onInit();
    _initializeSubscriptionListener();
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
      final expires = (data['expires_on'] as Timestamp).toDate();
      
      // Check if subscription is still active
      if (expires.isAfter(now)) {
        if (latestExpiry == null || expires.isAfter(latestExpiry)) {
          activePlan = data['plan_id'] as String;
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

  // ==================== FEATURE PERMISSION CHECKS ====================

  /// Check if user can perform a swipe action
  /// Returns true if within limit or has unlimited swipes
  Future<bool> canSwipe() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final limit = swipeLimits[currentPlanId.value] ?? 0;
    
    // Premium users have unlimited swipes
    if (limit == -1) return true;

    // Check today's swipe count
    final todaySwipes = await _getTodaySwipeCount(userId);
    return todaySwipes < limit;
  }

  /// Check if user can see who requested a match
  bool canSeeLikes() {
    return currentPlanId.value == 'plus' || currentPlanId.value == 'premium';
  }

  /// Check if user can send super likes
  bool canSuperLike() {
    return currentPlanId.value == 'premium';
  }

  /// Check if user can send more super likes this month
  Future<bool> canSendSuperLike() async {
    if (!canSuperLike()) return false;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final monthSuperLikes = await _getMonthSuperLikeCount(userId);
    return monthSuperLikes < 5; // 5 super likes per month limit
  }

  /// Get remaining swipes for today
  Future<int> getRemainingSwipes() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 0;

    final limit = swipeLimits[currentPlanId.value] ?? 0;
    if (limit == -1) return -1; // Unlimited

    final todaySwipes = await _getTodaySwipeCount(userId);
    final remaining = limit - todaySwipes;
    return remaining > 0 ? remaining : 0;
  }

  /// Get remaining super likes for this month
  Future<int> getRemainingSuperLikes() async {
    if (!canSuperLike()) return 0;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return 0;

    final monthSuperLikes = await _getMonthSuperLikeCount(userId);
    final remaining = 5 - monthSuperLikes;
    return remaining > 0 ? remaining : 0;
  }

  /// Get daily swipe limit based on current plan
  int getDailySwipeLimit() {
    return swipeLimits[currentPlanId.value] ?? 0;
  }

  // ==================== PRIVATE HELPER METHODS ====================

  /// Get today's swipe count for user
  Future<int> _getTodaySwipeCount(String userId) async {
    try {
      final today = _getTodayDateString();
      final doc = await _firestore
          .collection('UserSwipes')
          .doc(userId)
          .collection('dates')
          .doc(today)
          .get();

      if (!doc.exists) return 0;

      final data = doc.data();
      return (data?['count'] as int?) ?? 0;
    } catch (e) {
      print('Error getting swipe count: $e');
      return 0;
    }
  }

  /// Get this month's super like count for user
  Future<int> _getMonthSuperLikeCount(String userId) async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      
      final snapshot = await _firestore
          .collection('SuperLikes')
          .where('sender_id', isEqualTo: userId)
          .where('super_liked_on', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting super like count: $e');
      return 0;
    }
  }

  /// Get today's date as string in yyyy-MM-dd format
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get formatted expiry date string
  String? getExpiryDateFormatted() {
    if (expiresOn.value == null) return null;
    final date = expiresOn.value!;
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get days remaining until expiry
  int? getDaysRemaining() {
    if (expiresOn.value == null) return null;
    final diff = expiresOn.value!.difference(DateTime.now());
    return diff.inDays;
  }

  /// Check if subscription is expiring soon (within 3 days)
  bool isExpiringSoon() {
    final days = getDaysRemaining();
    return days != null && days <= 3 && days > 0;
  }
}