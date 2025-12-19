import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/payment_transactions_controller.dart';
import 'package:twinkle/controllers/subscriptions_controller.dart';

/// Main subscription page displaying all available plans
/// Shows Free, Plus, and Premium options with features and pricing
class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subscriptionController = Get.find<SubscriptionController>();
    final paymentController = Get.find<PaymentTransactionsController>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (subscriptionController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.pinkAccent),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current plan status
              _buildCurrentPlanStatus(subscriptionController),
              const SizedBox(height: 30),

              // Plans
              _buildPlanCard(
                planId: 'free',
                planName: 'Free',
                price: 0,
                features: [
                  '10 swipes per day',
                  'Basic matching',
                  'Send messages',
                ],
                isCurrentPlan: subscriptionController.currentPlanId.value == 'free',
                isRecommended: false,
                onTap: () {
                  // Free plan - no action needed
                  Get.snackbar(
                    'Current Plan',
                    'You are already on the Free plan',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              const SizedBox(height: 20),

              _buildPlanCard(
                planId: 'plus',
                planName: 'Plus',
                price: 200000,
                features: [
                  '50 swipes per day',
                  'See who likes you',
                  'Send unlimited messages',
                  'Priority support',
                ],
                isCurrentPlan: subscriptionController.currentPlanId.value == 'plus',
                isRecommended: false,
                onTap: () async {
                  _showPurchaseConfirmation(
                    context,
                    'plus',
                    'Plus',
                    200000,
                    paymentController,
                  );
                },
              ),
              const SizedBox(height: 20),

              _buildPlanCard(
                planId: 'premium',
                planName: 'Premium',
                price: 400000,
                features: [
                  'Unlimited swipes',
                  'See who likes you',
                  '5 Super Likes per month',
                  'Send unlimited messages',
                  'Priority support',
                  'Premium badge',
                ],
                isCurrentPlan: subscriptionController.currentPlanId.value == 'premium',
                isRecommended: true,
                onTap: () async {
                  _showPurchaseConfirmation(
                    context,
                    'premium',
                    'Premium',
                    400000,
                    paymentController,
                  );
                },
              ),
              const SizedBox(height: 30),

              // Transaction history button
              if (paymentController.hasPaymentHistory())
                Center(
                  child: TextButton.icon(
                    onPressed: () => Get.toNamed('/transaction-history'),
                    icon: const Icon(Icons.history, color: Colors.white70),
                    label: const Text(
                      'View Transaction History',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentPlanStatus(SubscriptionController controller) {
    final planName = controller.currentPlanId.value.capitalize;
    final daysRemaining = controller.getDaysRemaining();
    final expiryDate = controller.getExpiryDateFormatted();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.card_membership, color: Colors.pinkAccent, size: 24),
              const SizedBox(width: 10),
              const Text(
                'Current Plan',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            planName ?? 'Free',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (daysRemaining != null && expiryDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Expires on $expiryDate',
              style: TextStyle(
                color: controller.isExpiringSoon() ? Colors.orangeAccent : Colors.white60,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$daysRemaining days remaining',
              style: TextStyle(
                color: controller.isExpiringSoon() ? Colors.orangeAccent : Colors.white60,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String planId,
    required String planName,
    required int price,
    required List<String> features,
    required bool isCurrentPlan,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended
              ? Colors.pinkAccent
              : isCurrentPlan
                  ? Colors.greenAccent
                  : Colors.white12,
          width: isRecommended || isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badge
          if (isRecommended || isCurrentPlan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isRecommended ? Colors.pinkAccent : Colors.greenAccent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Text(
                isCurrentPlan ? 'CURRENT PLAN' : 'RECOMMENDED',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan name and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      planName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price == 0 ? 'Free' : '${_formatPrice(price)} ₫',
                          style: TextStyle(
                            color: isRecommended ? Colors.pinkAccent : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (price > 0)
                          const Text(
                            '/month',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Features list
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: isRecommended ? Colors.pinkAccent : Colors.greenAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan ? null : onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended ? Colors.pinkAccent : Colors.white,
                      foregroundColor: isRecommended ? Colors.white : Colors.black,
                      disabledBackgroundColor: Colors.white24,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isCurrentPlan ? 'Current Plan' : 'Upgrade Now',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showPurchaseConfirmation(
    BuildContext context,
    String planId,
    String planName,
    int amount,
    PaymentTransactionsController paymentController,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Confirm Purchase',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are about to purchase:',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Text(
                '$planName Plan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_formatPrice(amount)} ₫/month',
                style: const TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            Obx(() {
              return ElevatedButton(
                onPressed: paymentController.isProcessingPayment.value
                    ? null
                    : () async {
                        final success = await paymentController.purchaseSubscription(
                          planId,
                          amount,
                        );
                        if (success) {
                          Navigator.of(context).pop();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: paymentController.isProcessingPayment.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Confirm Purchase'),
              );
            }),
          ],
        );
      },
    );
  }
}