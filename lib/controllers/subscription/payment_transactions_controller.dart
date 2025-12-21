import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twinkle/controllers/subscription/subscriptions_controller.dart';
import 'package:twinkle/models/payment_transactions_model.dart';
import 'package:twinkle/models/user_subscriptions_model.dart';
import 'package:twinkle/models/subscription_plans_model.dart';
import 'package:twinkle/services/subscription/vnpay/vnpay_service.dart';
import 'package:twinkle/services/subscription/zalopay/zalopay_service.dart';

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
  final RxString selectedPaymentMethod = 'zalopay'.obs;
  
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
      _showErrorDialog(
        'Login Required',
        'Please login to continue with your purchase.',
      );
      return false;
    }

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
      _showErrorDialog(
        'Payment Error',
        'An error occurred during payment process. Please try again.',
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
      _showErrorDialog(
        'Order Creation Failed',
        orderResult['message'] ?? 'Could not create order. Please try again.',
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
      _showWarningDialog(
        'Install ZaloPay',
        'Please install the ZaloPay app to proceed with the payment.',
      );
      return false;
    }

    if (!launchResult['success']) {
      _showErrorDialog(
        'Launch Failed',
        launchResult['message'] ?? 'Could not open ZaloPay app.',
      );
      return false;
    }

    // Wait a bit for user to complete payment in ZaloPay app
    await Future.delayed(const Duration(milliseconds: 500));

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

    _pendingTransactionData = {
      'plan_id': plan_id,
      'plan_name': plan_name,
      'amount': amount,
      'user_id': user_id,
      'payment_method': 'vnpay',
    };

    try {
      final paymentResult = await _vnPayService.createPaymentAndShow(
        context: context,
        plan_id: plan_id,
        plan_name: plan_name,
        amount: amount.toDouble(),
        user_id: user_id,
      );

      print('Payment result: $paymentResult');

      if (!paymentResult['success']) {
        _showErrorDialog(
          'Payment Failed',
          paymentResult['message'] ?? 'Could not create payment.',
        );
        return false;
      }

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
        _showWarningDialog(
          'Payment Unsuccessful',
          paymentResult['message'] ?? 'Transaction was not completed.',
        );
        return false;
      }
    } catch (e) {
      print('❌ Error in VNPay payment: $e');
      _showErrorDialog(
        'Payment Error',
        'An error occurred while processing your payment.',
      );
      return false;
    }
  }

  /// Handle VNPay callback from deep link
  Future<bool> handleVNPayCallback(String callbackUrl) async {
    try {
      final params = _vnPayService.parseCallbackUrl(callbackUrl);
      final result = _vnPayService.verifyCallback(params);

      if (!result['success']) {
        _showErrorDialog(
          'Verification Failed',
          result['message'] ?? 'Payment verification failed.',
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
        _showWarningDialog(
          'Payment Failed',
          result['message'] ?? 'Transaction was not successful.',
        );
        return false;
      }
    } catch (e) {
      print('❌ Error handling callback: $e');
      return false;
    }
  }

  /// Show payment verification dialog
  Future<bool?> _showPaymentVerificationDialog(String paymentMethodName) async {
    return await Get.dialog<bool>(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Confirm Payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Have you completed the payment via $paymentMethodName?',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'After successful payment, tap "Payment Complete" to activate your plan.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.4,
                ),
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
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Payment Complete',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
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
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Colors.pinkAccent,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Verifying payment...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please wait',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final queryResult = await _zaloPayService.waitForPaymentConfirmation(
        _currentTxnRef!,
        maxAttempts: 8,
        interval: const Duration(seconds: 3),
      );

      Get.back(); // Close loading

      if (!queryResult['success'] || queryResult['isPaid'] != true) {
        _showWarningDialog(
          'Verification Failed',
          queryResult['message'] ?? 'Could not confirm payment status.',
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

      // Create transaction record
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

      // Create subscription
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

      _showSuccessDialog(
        'Success!',
        'Your subscription has been activated successfully.',
      );

      // Clear pending
      _currentTxnRef = null;
      _pendingTransactionData = null;

      return true;
    } catch (e) {
      print('Error activating subscription: $e');
      _showErrorDialog(
        'Activation Failed',
        'Could not activate subscription. Please contact support.',
      );
      return false;
    }
  }

  /// Show error dialog
  void _showErrorDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show warning dialog
  void _showWarningDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  void _showSuccessDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Great!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fallback plan name
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