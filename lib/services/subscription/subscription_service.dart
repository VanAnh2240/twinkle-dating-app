import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service layer for handling all Firestore operations related to subscriptions
class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get all available subscription plans
  Future<List<Map<String, dynamic>>> getAllPlans() async {
    try {
      final snapshot = await _firestore
          .collection('SubscriptionPlans')
          .orderBy('price')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'plan_id': doc.id,
          'plan_name': data['plan_name'],
          'price': data['price'],
          'duration_days': data['duration_days'],
        };
      }).toList();
    } catch (e) {
      print('Error getting plans: $e');
      return [];
    }
  }

  /// Get specific plan by ID
  Future<Map<String, dynamic>?> getPlanById(String planId) async {
    try {
      final doc = await _firestore
          .collection('SubscriptionPlans')
          .doc(planId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data();
      return {
        'plan_id': doc.id,
        'plan_name': data?['plan_name'],
        'price': data?['price'],
        'duration_days': data?['duration_days'],
      };
    } catch (e) {
      print('Error getting plan: $e');
      return null;
    }
  }

  /// Initialize default subscription plans (run once on first app launch)
  Future<void> initializeDefaultPlans() async {
    try {
      // Check if plans already exist
      final existingPlans = await _firestore
          .collection('SubscriptionPlans')
          .limit(1)
          .get();

      if (existingPlans.docs.isNotEmpty) {
        print('Plans already initialized');
        return;
      }

      // Create Free plan (eternal - no expiry)
      await _firestore.collection('SubscriptionPlans').doc('free').set({
        'plan_id': 'free',
        'plan_name': 'Free',
        'price': 0,
        'duration_days': 0, // 0 means eternal/no expiry
      });

      // Create Plus plan (30 days)
      await _firestore.collection('SubscriptionPlans').doc('plus').set({
        'plan_id': 'plus',
        'plan_name': 'Plus',
        'price': 199000,
        'duration_days': 30,
      });

      // Create Premium plan (30 days)
      await _firestore.collection('SubscriptionPlans').doc('premium').set({
        'plan_id': 'premium',
        'plan_name': 'Premium',
        'price': 399000,
        'duration_days': 30,
      });

      print('Subscription plans initialized successfully');
    } catch (e) {
      print('Error initializing plans: $e');
    }
  }

  /// Get feature list for each plan
  Map<String, List<String>> getPlanFeatures() {
    return {
      'free': [
        '10 swipes per day',
      ],
      'plus': [
        '50 swipes per day',
        'See who likes you',
        '5 Super Likes per month',
        'See who super liked you',
        'Priority support',
      ],
      'premium': [
        'Unlimited swipes',
        'See who likes you',
        '10 Super Likes per month',
        'See people blocked and unblocked',
        'Priority support',
        'Premium badge',
      ],
    };
  }

  /// Get swipe limits for each plan
  Map<String, int> getSwipeLimits() {
    return {
      'free': 10,
      'plus': 50,
      'premium': -1, // -1 means unlimited
    };
  }

  /// Get super likes limit for each plan
  Map<String, int> getSuperLikesLimits() {
    return {
      'free': 0,
      'plus': 5,
      'premium': 10,
    };
  }

  /// Format price in VND
  String formatPrice(int price) {
    if (price == 0) return 'Miễn phí';
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}₫';
  }

  /// Get user's active subscription
  Future<Map<String, dynamic>?> getUserActiveSubscription(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('UserSubscriptions')
          .where('user_id', isEqualTo: userId)
          .orderBy('subscribed_on', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();
      final expiresOn = _parseDateTime(data['expires_on']);
      final now = DateTime.now();

      // Check if subscription is still active
      // Free plan or not expired
      if (data['plan_id'] == 'free' || expiresOn.isAfter(now)) {
        return {
          'subscription_id': data['subscription_id'],
          'user_id': data['user_id'],
          'plan_id': data['plan_id'],
          'subscribed_on': _parseDateTime(data['subscribed_on']),
          'expires_on': expiresOn,
        };
      }

      // Subscription expired - return null
      return null;
    } catch (e) {
      print('Error fetching user subscription: $e');
      return null;
    }
  }

  /// Get user's current plan ID (returns 'free' if no active subscription)
  Future<String> getUserCurrentPlanId(String userId) async {
    final activeSubscription = await getUserActiveSubscription(userId);
    return activeSubscription?['plan_id'] ?? 'free';
  }

  /// Create a new subscription for user
  Future<bool> createSubscription({
    required String userId,
    required String planId,
    required int durationDays,
  }) async {
    try {
      final now = DateTime.now();
      DateTime expiresOn;

      // For free plan (duration_days = 0), set far future date
      if (durationDays == 0) {
        expiresOn = DateTime(2099, 12, 31); // Far future date
      } else {
        expiresOn = now.add(Duration(days: durationDays));
      }

      final subscriptionId = _firestore.collection('UserSubscriptions').doc().id;

      await _firestore
          .collection('UserSubscriptions')
          .doc(subscriptionId)
          .set({
        'subscription_id': subscriptionId,
        'user_id': userId,
        'plan_id': planId,
        'subscribed_on': now.millisecondsSinceEpoch,
        'expires_on': expiresOn.millisecondsSinceEpoch,
      });

      return true;
    } catch (e) {
      print('Error creating subscription: $e');
      return false;
    }
  }

  /// Create initial free subscription for new user
  Future<bool> createFreeSubscriptionForNewUser(String userId) async {
    try {
      // Check if user already has a subscription
      final existing = await getUserActiveSubscription(userId);
      if (existing != null) {
        print('User already has a subscription');
        return true;
      }

      return await createSubscription(
        userId: userId,
        planId: 'free',
        durationDays: 0, // Eternal
      );
    } catch (e) {
      print('Error creating free subscription: $e');
      return false;
    }
  }

  /// Upgrade user subscription
  Future<bool> upgradeSubscription({
    required String userId,
    required String newPlanId,
    required int durationDays,
  }) async {
    try {
      // Create new subscription (old ones will become inactive automatically)
      return await createSubscription(
        userId: userId,
        planId: newPlanId,
        durationDays: durationDays,
      );
    } catch (e) {
      print('Error upgrading subscription: $e');
      return false;
    }
  }

  /// Create a payment transaction
  Future<String?> createPaymentTransaction({
    required String userId,
    required int amount,
    required String paymentMethod,
    required String planId,
  }) async {
    try {
      final transactionId = _firestore.collection('PaymentTransactions').doc().id;
      
      await _firestore
          .collection('PaymentTransactions')
          .doc(transactionId)
          .set({
        'transaction_id': transactionId,
        'user_id': userId,
        'amount': amount,
        'transaction_date': DateTime.now().millisecondsSinceEpoch,
        'payment_method': paymentMethod,
        'plan_id': planId,
        'status': 'pending',
      });

      return transactionId;
    } catch (e) {
      print('Error creating payment transaction: $e');
      return null;
    }
  }

  /// Update payment transaction status
  Future<bool> updateTransactionStatus({
    required String transactionId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection('PaymentTransactions')
          .doc(transactionId)
          .update({
        'status': status,
      });

      return true;
    } catch (e) {
      print('Error updating transaction status: $e');
      return false;
    }
  }

  /// Complete purchase flow: create transaction + subscription
  Future<bool> completePurchase({
    required String planId,
    required int amount,
    required String paymentMethod,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      // 1. Create payment transaction
      final transactionId = await createPaymentTransaction(
        userId: userId,
        amount: amount,
        paymentMethod: paymentMethod,
        planId: planId,
      );

      if (transactionId == null) return false;

      // 2. Get plan details
      final planData = await getPlanById(planId);
      if (planData == null) {
        await updateTransactionStatus(
          transactionId: transactionId,
          status: 'failed',
        );
        return false;
      }

      final durationDays = planData['duration_days'] as int;

      // 3. Upgrade subscription
      final subscriptionCreated = await upgradeSubscription(
        userId: userId,
        newPlanId: planId,
        durationDays: durationDays,
      );

      if (!subscriptionCreated) {
        await updateTransactionStatus(
          transactionId: transactionId,
          status: 'failed',
        );
        return false;
      }

      // 4. Mark transaction as success
      await updateTransactionStatus(
        transactionId: transactionId,
        status: 'success',
      );

      return true;
    } catch (e) {
      print('Error completing purchase: $e');
      return false;
    }
  }

  /// Get user's payment history
  Future<List<Map<String, dynamic>>> getUserPaymentHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('PaymentTransactions')
          .where('user_id', isEqualTo: userId)
          .orderBy('transaction_date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'transaction_id': data['transaction_id'],
          'user_id': data['user_id'],
          'amount': data['amount'],
          'transaction_date': _parseDateTime(data['transaction_date']),
          'payment_method': data['payment_method'] ?? 'unknown',
          'plan_id': data['plan_id'] ?? 'unknown',
          'status': data['status'] ?? 'pending',
        };
      }).toList();
    } catch (e) {
      print('Error fetching payment history: $e');
      return [];
    }
  }

  /// Parse DateTime from various formats
  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  /// Check if user has Plus plan
  Future<bool> isUserPlus(String userId) async {
    final planId = await getUserCurrentPlanId(userId);
    return planId == 'plus';
  }

  /// Check if user has Premium plan
  Future<bool> isUserPremium(String userId) async {
    final planId = await getUserCurrentPlanId(userId);
    return planId == 'premium';
  }

  /// Check if user has any paid plan (Plus or Premium)
  Future<bool> isUserPaid(String userId) async {
    final planId = await getUserCurrentPlanId(userId);
    return planId == 'plus' || planId == 'premium';
  }

  /// Check if user has Free plan
  Future<bool> isUserFree(String userId) async {
    final planId = await getUserCurrentPlanId(userId);
    return planId == 'free';
  }

  /// Get comprehensive user subscription info
  Future<Map<String, dynamic>> getUserSubscriptionInfo(String userId) async {
    final activeSubscription = await getUserActiveSubscription(userId);
    final planId = activeSubscription?['plan_id'] ?? 'free';
    
    return {
      'plan_id': planId,
      'is_free': planId == 'free',
      'is_plus': planId == 'plus',
      'is_premium': planId == 'premium',
      'is_paid': planId == 'plus' || planId == 'premium',
      'expires_on': activeSubscription?['expires_on'],
      'subscribed_on': activeSubscription?['subscribed_on'],
    };
  }
}