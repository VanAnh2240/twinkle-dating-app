import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twinkle/services/payment/vnpay/vnpay_service.dart';
import 'package:twinkle/services/payment/zalopay/zalopay_service.dart';
import 'package:twinkle/models/payment_transactions_model.dart';
import 'package:twinkle/models/user_subscriptions_model.dart';
import 'package:twinkle/models/subscription_plans_model.dart';
import 'package:twinkle/controllers/subscriptions_controller.dart';

/// Controller for managing payment transactions with multiple payment gateways
class PaymentTransactionsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ZaloPayService _zaloPayService = ZaloPayService();
  final VNPayService _vnPayService = VNPayService();

  // Reactive state
  final RxList<PaymentTransactionsModel> transactions = <PaymentTransactionsModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessingPayment = false.obs;
  final RxString selectedPaymentMethod = 'zalopay'.obs; // 'zalopay' or 'vnpay'
  
  // Subscription plans cache
  final RxMap<String, SubscriptionPlansModel> plans = <String, SubscriptionPlansModel>{}.obs;
  
  // Pending transaction info
  String? _currentTxnRef;
  Map<String, dynamic>? _pendingTransactionData;
  String? _currentPaymentMethod;

  @override
  void onInit() {
    super.onInit();
    loadTransactionHistory();
    _loadSubscriptionPlans();
  }

  /// Load subscription plans from Firestore
  Future<void> _loadSubscriptionPlans() async {
    try {
      final snapshot = await _firestore.collection('SubscriptionPlans').get();
      
      for (var doc in snapshot.docs) {
        final plan = SubscriptionPlansModel.fromMap(doc.data());
        plans[plan.plan_id] = plan;
      }
    } catch (e) {
      print('Error loading subscription plans: $e');
    }
  }

  /// Load transaction history
  Future<void> loadTransactionHistory() async {
    final user_id = _auth.currentUser?.uid;
    if (user_id == null) return;

    isLoading.value = true;

    try {
      final snapshot = await _firestore
          .collection('PaymentTransactions')
          .where('user_id', isEqualTo: user_id)
          .orderBy('transaction_date', descending: true)
          .get();

      transactions.value = snapshot.docs
          .map((doc) => PaymentTransactionsModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Main purchase flow with payment method selection
  Future<bool> purchaseSubscription(
    BuildContext context,
    String plan_id,
    int amount, {
    String? paymentMethod,
  }) async {
    final user_id = _auth.currentUser?.uid;
    if (user_id == null) {
      Get.snackbar(
        'Error',
        'Please login to continue',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // Use selected payment method or default
    final method = paymentMethod ?? selectedPaymentMethod.value;
    _currentPaymentMethod = method;

    isProcessingPayment.value = true;

    try {
      if (method == 'vnpay') {
        return await _purchaseWithVNPay(context, plan_id, amount, user_id);
      } else {
        return await _purchaseWithZaloPay(plan_id, amount, user_id);
      }
    } catch (e) {
      print('Error in purchase flow: $e');
      Get.snackbar(
        'Error',
        'Error in purchase flow: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.2),
      );
      return false;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Purchase with ZaloPay
  Future<bool> _purchaseWithZaloPay(String plan_id, int amount, String user_id) async {
    print('Processing with ZaloPay...');

    final plan = plans[plan_id];
    final plan_name = plan?.plan_name ?? _getplan_nameFallback(plan_id);
    
    final orderResult = await _zaloPayService.createOrder(
      plan_id: plan_id,
      plan_name: plan_name,
      amount: amount,
      user_id: user_id,
    );

    if (!orderResult['success']) {
      Get.snackbar(
        'Error',
        orderResult['message'] ?? 'Could not create order',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.2),
      );
      return false;
    }

    _currentTxnRef = orderResult['appTransId'];
    _pendingTransactionData = {
      'plan_id': plan_id,
      'amount': amount,
      'txnRef': _currentTxnRef,
      'paymentMethod': 'zalopay',
    };

    final launchResult = await _zaloPayService.openZaloPayApp(
      orderResult['orderUrl'],
    );

    if (launchResult['needsInstall'] == true) {
      Get.snackbar(
        'Install ZaloPay',
        'Please install the ZaloPay app to proceed with the payment.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.orangeAccent.withOpacity(0.2),
      );
      return false;
    }

    if (!launchResult['success']) {
      Get.snackbar(
        'Error',
        launchResult['message'] ?? 'Could not open ZaloPay',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.2),
      );
      return false;
    }

    final shouldVerify = await _showPaymentVerificationDialog('ZaloPay');
    if (shouldVerify == true) {
      return await _verifyZaloPayAndActivate();
    }

    return false;
  }

  /// Purchase with VNPay
  Future<bool> _purchaseWithVNPay(
    BuildContext context,
    String plan_id,
    int amount,
    String user_id,
  ) async {
    print('Processing with VNPay...');

    final plan = plans[plan_id];
    final plan_name = plan?.plan_name ?? _getplan_nameFallback(plan_id);

    // Store pending data before payment
    _pendingTransactionData = {
      'plan_id': plan_id,
      'plan_name': plan_name,
      'amount': amount,
      'user_id': user_id,
      'payment_method': 'vnpay',
    };

    try {
      // Create payment and show VNPay WebView using package's built-in method
      final paymentResult = await _vnPayService.createPaymentAndShow(
        context: context,
        plan_id: plan_id,
        plan_name: plan_name,
        amount: amount.toDouble(),
        user_id: user_id,
      );

      print('Payment result: $paymentResult');

      if (!paymentResult['success']) {
        Get.snackbar(
          'Error',
          paymentResult['message'] ?? 'Could not create payment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.2),
        );
        return false;
      }

      // Check payment result
      if (paymentResult['isPaid'] == true) {
        _currentTxnRef = paymentResult['txnRef'];
        
        return await _activateSubscription(
          txnRef: paymentResult['txnRef'],
          amount: paymentResult['amount'],
          paymentMethod: 'vnpay',
          additionalData: {
            'bank_code': paymentResult['bankCode'],
            'transaction_no': paymentResult['transactionNo'],
            'response_code': paymentResult['responseCode'],
          },
        );
      } else {
        Get.snackbar(
          'Payment Failed',
          paymentResult['message'] ?? 'Transaction unsuccessful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent.withOpacity(0.2),
        );
        return false;
      }
    } catch (e) {
      print('❌ Error in VNPay payment: $e');
      Get.snackbar(
        'Error',
        'Error processing payment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.2),
      );
      return false;
    }
  }

  /// Handle VNPay callback from deep link (if needed)
  Future<bool> handleVNPayCallback(String callbackUrl) async {
    try {
      final params = _vnPayService.parseCallbackUrl(callbackUrl);
      final result = _vnPayService.verifyCallback(params);

      if (!result['success']) {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Verification failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.2),
        );
        return false;
      }

      if (result['isPaid'] == true) {
        return await _activateSubscription(
          txnRef: result['txnRef'],
          amount: result['amount'],
          paymentMethod: 'vnpay',
          additionalData: {
            'bank_code': result['bankCode'],
            'bank_tran_no': result['bankTranNo'],
            'card_type': result['cardType'],
            'transaction_no': result['transactionNo'],
          },
        );
      } else {
        Get.snackbar(
          'Payment Failed',
          result['message'] ?? 'Transaction unsuccessful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent.withOpacity(0.2),
        );
        return false;
      }
    } catch (e) {
      print('❌ Error handling callback: $e');
      return false;
    }
  }

  /// Show verification dialog
  Future<bool?> _showPaymentVerificationDialog(String paymentMethodName) async {
    return await Get.dialog<bool>(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.payment, color: Colors.pinkAccent, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Confirm Payment',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Have you completed the payment via $paymentMethodName?',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              SizedBox(height: 12),
              Text(
                'After successful payment, click "Payment Complete" to activate your plan.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _currentTxnRef = null;
                _pendingTransactionData = null;
                Get.back(result: false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Payment Complete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Verify ZaloPay payment
  Future<bool> _verifyZaloPayAndActivate() async {
    if (_currentTxnRef == null) return false;

    try {
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Card(
              color: Color(0xFF1E1E1E),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.pinkAccent),
                    SizedBox(height: 16),
                    Text(
                      'Verifying payment...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final queryResult = await _zaloPayService.waitForPaymentConfirmation(
        _currentTxnRef!,
        maxAttempts: 8,
        interval: Duration(seconds: 3),
      );

      Get.back(); // Close loading

      if (!queryResult['success'] || queryResult['isPaid'] != true) {
        Get.snackbar(
          'Verification Failed',
          queryResult['message'] ?? 'Could not confirm payment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent.withOpacity(0.2),
        );
        return false;
      }

      return await _activateSubscription(
        txnRef: _currentTxnRef!,
        amount: queryResult['amount'],
        paymentMethod: 'zalopay',
        additionalData: {
          'zp_trans_id': queryResult['zpTransId'],
        },
      );
    } catch (e) {
      Get.back(); // Close loading if error
      print('❌ Error verifying: $e');
      return false;
    }
  }

  /// Activate subscription after successful payment
  Future<bool> _activateSubscription({
    required String txnRef,
    required int amount,
    required String paymentMethod,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user_id = _auth.currentUser?.uid;
      if (user_id == null || _pendingTransactionData == null) return false;

      print('Activating subscription...');

      final plan_id = _pendingTransactionData!['plan_id'];
      final plan = plans[plan_id];
      final durationDays = plan?.duration_days ?? 30;

      // Create transaction record using Model
      final transaction = PaymentTransactionsModel(
        transaction_id: _firestore.collection('PaymentTransactions').doc().id,
        user_id: user_id,
        amount: amount.toDouble(),
        transaction_date: DateTime.now(),
        payment_method: paymentMethod,
        status: 'success',
      );

      await _firestore
          .collection('PaymentTransactions')
          .doc(transaction.transaction_id)
          .set({
        ...transaction.toMap(),
        'txn_ref': txnRef,
        ...?additionalData,
      });

      // Create subscription using Model
      final now = DateTime.now();
      final expiresOn = now.add(Duration(days: durationDays));
      
      final subscription = UserSubscriptionsModel(
        subscription_id: _firestore.collection('UserSubscriptions').doc().id,
        user_id: user_id,
        plan_id: plan_id,
        subscribed_on: now,
        expires_on: expiresOn,
      );

      await _firestore
          .collection('UserSubscriptions')
          .doc(subscription.subscription_id)
          .set(subscription.toMap());

      // Refresh data
      await loadTransactionHistory();
      final subscriptionController = Get.find<SubscriptionController>();
      await subscriptionController.refreshSubscription();

      Get.snackbar(
        'Success! 🎉',
        'Subscription has been activated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.greenAccent.withOpacity(0.2),
        duration: Duration(seconds: 3),
      );

      // Clear pending
      _currentTxnRef = null;
      _pendingTransactionData = null;

      return true;
    } catch (e) {
      print('Error activating subscription: $e');
      Get.snackbar(
        'Error',
        'Could not activate subscription',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.2),
      );
      return false;
    }
  }

  /// Fallback plan name if plans haven't loaded yet
  String _getplan_nameFallback(String plan_id) {
    switch (plan_id) {
      case 'plus':
        return 'Plus';
      case 'premium':
        return 'Premium';
      default:
        return 'Free';
    }
  }

  // ==================== UTILITY METHODS ====================

  int getTotalSpent() {
    return transactions.fold<int>(
      0,
      (sum, transaction) => sum + transaction.amount.toInt(),
    );
  }

  int getTransactionCount() => transactions.length;

  DateTime? getLastTransactionDate() {
    if (transactions.isEmpty) return null;
    return transactions.first.transaction_date;
  }

  bool hasPaymentHistory() => transactions.isNotEmpty;

  String formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} ₫';
  }

  String formatTransactionDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String getPaymentStatusMessage() {
    if (transactions.isEmpty) return 'No transactions';

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
      return 'Last payment on ${formatTransactionDate(lastDate)}';
    }
  }

  SubscriptionPlansModel? getPlanById(String plan_id) => plans[plan_id];
}