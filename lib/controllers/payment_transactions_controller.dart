import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twinkle/controllers/subscriptions_controller.dart';
import 'package:twinkle/services/zalopay/zalopay_service.dart';

/// Controller for managing payment transactions and subscription purchases
class PaymentTransactionsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ZaloPayService _zaloPayService = ZaloPayService();

  // Reactive state
  final RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessingPayment = false.obs;
  
  // Pending transaction info
  String? _currentAppTransId;
  Map<String, dynamic>? _pendingTransactionData;

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
          'status': data['status'] ?? 'completed',
          'payment_method': data['payment_method'] ?? 'zalopay',
          'app_trans_id': data['app_trans_id'],
        };
      }).toList();
    } catch (e) {
      print('Error loading transactions: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tải lịch sử giao dịch',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Main purchase flow
  Future<bool> purchaseSubscription(String planId, int amount) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng đăng nhập để tiếp tục',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isProcessingPayment.value = true;

    try {
      // Step 1: Create order
      print('🛒 Step 1: Creating order...');
      
      final planName = _getPlanName(planId);
      final orderResult = await _zaloPayService.createOrder(
        planId: planId,
        planName: planName,
        amount: amount,
        userId: userId,
      );

      if (!orderResult['success']) {
        Get.snackbar(
          'Lỗi',
          orderResult['message'] ?? 'Không thể tạo đơn hàng',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.2),
        );
        return false;
      }

      print('✅ Order created: ${orderResult['appTransId']}');

      // Save pending transaction
      _currentAppTransId = orderResult['appTransId'];
      _pendingTransactionData = {
        'planId': planId,
        'amount': amount,
        'appTransId': _currentAppTransId,
      };

      // Step 2: Open ZaloPay app
      print('🚀 Step 2: Opening ZaloPay app...');
      
      final launchResult = await _zaloPayService.openZaloPayApp(
        orderResult['orderUrl'],
      );

      if (launchResult['needsInstall'] == true) {
        Get.snackbar(
          'Cài đặt ZaloPay',
          'Vui lòng cài đặt ứng dụng ZaloPay từ CH Play/App Store',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.orangeAccent.withOpacity(0.2),
        );
        return false;
      }

      if (!launchResult['success']) {
        Get.snackbar(
          'Lỗi',
          launchResult['message'] ?? 'Không thể mở ZaloPay',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.2),
        );
        return false;
      }

      print('✅ ZaloPay opened');

      // Step 3: Show verification dialog
      print('⏰ Step 3: Waiting for payment confirmation...');
      
      final shouldVerify = await _showPaymentVerificationDialog();

      if (shouldVerify == true) {
        return await _verifyAndActivateSubscription();
      }

      return false;
    } catch (e) {
      print('❌ Error in purchase flow: $e');
      Get.snackbar(
        'Lỗi',
        'Có lỗi xảy ra: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.2),
      );
      return false;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Show dialog asking user if they completed payment
  Future<bool?> _showPaymentVerificationDialog() async {
    return await Get.dialog<bool>(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.payment, color: Colors.pinkAccent, size: 28),
              SizedBox(width: 12),
              Text(
                'Xác nhận thanh toán',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Bạn đã hoàn tất thanh toán trong ZaloPay chưa?',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              SizedBox(height: 12),
              Text(
                'Sau khi thanh toán thành công, nhấn "Đã thanh toán" để kích hoạt gói.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _currentAppTransId = null;
                _pendingTransactionData = null;
                Get.back(result: false);
              },
              child: const Text(
                'Hủy bỏ',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đã thanh toán',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Verify payment and activate subscription
  Future<bool> _verifyAndActivateSubscription() async {
    if (_currentAppTransId == null || _pendingTransactionData == null) {
      return false;
    }

    try {
      print('🔍 Verifying payment...');
      
      // Show loading
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: const Center(
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
                      'Đang xác minh thanh toán...',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vui lòng đợi trong giây lát',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Wait and query
      final queryResult = await _zaloPayService.waitForPaymentConfirmation(
        _currentAppTransId!,
        maxAttempts: 8,
        interval: const Duration(seconds: 3),
      );

      // Close loading dialog
      Get.back();

      if (!queryResult['success'] || queryResult['isPaid'] != true) {
        Get.snackbar(
          'Xác minh thất bại',
          queryResult['message'] ?? 'Không thể xác nhận thanh toán',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent.withOpacity(0.2),
          duration: const Duration(seconds: 4),
        );
        return false;
      }

      print('✅ Payment verified! Activating subscription...');

      // Activate subscription
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Create transaction record
      final transactionRef = _firestore.collection('PaymentTransactions').doc();
      await transactionRef.set({
        'transaction_id': transactionRef.id,
        'user_id': userId,
        'amount': _pendingTransactionData!['amount'],
        'transaction_date': FieldValue.serverTimestamp(),
        'status': 'completed',
        'payment_method': 'zalopay',
        'app_trans_id': _currentAppTransId,
        'zp_trans_id': queryResult['zpTransId'],
      });

      // Create subscription
      final subscriptionRef = _firestore.collection('UserSubscriptions').doc();
      final now = DateTime.now();
      final expiresOn = now.add(const Duration(days: 30));

      await subscriptionRef.set({
        'subscription_id': subscriptionRef.id,
        'user_id': userId,
        'plan_id': _pendingTransactionData!['planId'],
        'subscribed_on': Timestamp.fromDate(now),
        'expires_on': Timestamp.fromDate(expiresOn),
      });

      print('🎉 Subscription activated!');

      // Refresh data
      await loadTransactionHistory();
      final subscriptionController = Get.find<SubscriptionController>();
      await subscriptionController.refreshSubscription();

      Get.snackbar(
        'Thành công! 🎉',
        'Gói đăng ký đã được kích hoạt',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.greenAccent.withOpacity(0.2),
        duration: const Duration(seconds: 3),
      );

      // Clear pending
      _currentAppTransId = null;
      _pendingTransactionData = null;

      return true;
    } catch (e) {
      print('❌ Error verifying: $e');
      Get.back(); // Close loading if still open
      Get.snackbar(
        'Lỗi',
        'Không thể kích hoạt gói đăng ký: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.2),
      );
      return false;
    }
  }

  String _getPlanName(String planId) {
    switch (planId) {
      case 'plus':
        return 'Plus';
      case 'premium':
        return 'Premium';
      default:
        return 'Free';
    }
  }

  int getTotalSpent() {
    return transactions.fold<int>(
      0,
      (sum, transaction) => sum + (transaction['amount'] as int),
    );
  }

  int getTransactionCount() => transactions.length;

  DateTime? getLastTransactionDate() {
    if (transactions.isEmpty) return null;
    return transactions.first['transaction_date'] as DateTime;
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
    if (transactions.isEmpty) return 'Chưa có giao dịch';

    final lastDate = getLastTransactionDate();
    if (lastDate == null) return 'Chưa có thanh toán gần đây';

    final daysSince = DateTime.now().difference(lastDate).inDays;
    
    if (daysSince == 0) {
      return 'Thanh toán thành công hôm nay';
    } else if (daysSince == 1) {
      return 'Thanh toán lần cuối hôm qua';
    } else if (daysSince < 30) {
      return 'Thanh toán lần cuối $daysSince ngày trước';
    } else {
      return 'Thanh toán lần cuối ${formatTransactionDate(lastDate)}';
    }
  }
}