import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for handling subscription plan queries
/// Fetches available plans and manages subscription data
class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  /// Get specific plan details
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

  /// Initialize default subscription plans in Firestore
  /// This should be run once during app setup or by admin
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

      // Create Free plan
      await _firestore.collection('SubscriptionPlans').doc('free').set({
        'plan_id': 'free',
        'plan_name': 'Free',
        'price': 0,
        'duration_days': 30,
      });

      // Create Plus plan
      await _firestore.collection('SubscriptionPlans').doc('plus').set({
        'plan_id': 'plus',
        'plan_name': 'Plus',
        'price': 200000,
        'duration_days': 30,
      });

      // Create Premium plan
      await _firestore.collection('SubscriptionPlans').doc('premium').set({
        'plan_id': 'premium',
        'plan_name': 'Premium',
        'price': 400000,
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
        'Basic matching',
        'Send messages',
      ],
      'plus': [
        '50 swipes per day',
        'See who likes you',
        'Send unlimited messages',
        'Priority support',
      ],
      'premium': [
        'Unlimited swipes',
        'See who likes you',
        '5 Super Likes per month',
        'Send unlimited messages',
        'Priority support',
        'Premium badge',
      ],
    };
  }

  /// Format price in VND
  String formatPrice(int price) {
    if (price == 0) return 'Free';
    return '${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} ₫';
  }
}