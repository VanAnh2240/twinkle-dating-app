import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twinkle/controllers/subscriptions_controller.dart';

/// Controller for managing payment transactions and subscription purchases
/// Handles payment flow, transaction history, and subscription activation
class PaymentTransactionsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reactive state
  final RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessingPayment = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactionHistory();
  }

  /// Load user's transaction history from Firestore
  Future<void> loadTransactionHistory() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    isLoading.value = true;

    try {
      final snapshot = await _firestore
          .collection('PaymentTransactions')
          .where('user_id', isEqualTo: userId)
          .orderBy('transaction_date', descending: true)
          .get();

      transactions.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'transaction_id': doc.id,
          'amount': data['amount'],
          'transaction_date': (data['transaction_date'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      print('Error loading transactions: $e');
      Get.snackbar(
        'Error',
        'Failed to load transaction history',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Process subscription purchase
  /// This creates a payment transaction and activates the subscription
  Future<bool> purchaseSubscription(String planId, int amount) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      Get.snackbar(
        'Error',
        'Please login to continue',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isProcessingPayment.value = true;

    try {
      // Step 1: Create payment transaction
      final transactionRef = _firestore.collection('PaymentTransactions').doc();
      await transactionRef.set({
        'transaction_id': transactionRef.id,
        'user_id': userId,
        'amount': amount,
        'transaction_date': FieldValue.serverTimestamp(),
      });

      // Step 2: Create or update user subscription
      final subscriptionRef = _firestore.collection('UserSubscriptions').doc();
      final now = DateTime.now();
      final expiresOn = now.add(const Duration(days: 30));

      await subscriptionRef.set({
        'subscription_id': subscriptionRef.id,
        'user_id': userId,
        'plan_id': planId,
        'subscribed_on': Timestamp.fromDate(now),
        'expires_on': Timestamp.fromDate(expiresOn),
      });

      // Step 3: Refresh data
      await loadTransactionHistory();
      
      // Step 4: Update SubscriptionController
      final subscriptionController = Get.find<SubscriptionController>();
      await subscriptionController.refreshSubscription();

      Get.snackbar(
        'Success',
        'Subscription activated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return true;
    } catch (e) {
      print('Error processing payment: $e');
      Get.snackbar(
        'Error',
        'Payment failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Get total amount spent by user
  int getTotalSpent() {
    return transactions.fold<int>(
      0,
      (sum, transaction) => sum + (transaction['amount'] as int),
    );
  }

  /// Get transaction count
  int getTransactionCount() {
    return transactions.length;
  }

  /// Get last transaction date
  DateTime? getLastTransactionDate() {
    if (transactions.isEmpty) return null;
    return transactions.first['transaction_date'] as DateTime;
  }

  /// Check if user has any payment history
  bool hasPaymentHistory() {
    return transactions.isNotEmpty;
  }

  /// Format amount in VND currency
  String formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} ₫';
  }

  /// Get formatted transaction date
  String formatTransactionDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Get payment status message based on recent transactions
  String getPaymentStatusMessage() {
    if (transactions.isEmpty) {
      return 'No payment history';
    }

    final lastDate = getLastTransactionDate();
    if (lastDate == null) return 'No recent payments';

    final daysSince = DateTime.now().difference(lastDate).inDays;
    
    if (daysSince == 0) {
      return 'Payment successful today';
    } else if (daysSince == 1) {
      return 'Last payment yesterday';
    } else if (daysSince < 30) {
      return 'Last payment $daysSince days ago';
    } else {
      return 'Last payment ${formatTransactionDate(lastDate)}';
    }
  }
}