import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twinkle/controllers/subscription/payment_transactions_controller.dart';
import 'package:twinkle/controllers/subscription/subscriptions_controller.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subscriptionController = Get.find<SubscriptionController>();
    final paymentController = Get.find<PaymentTransactionsController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Obx(() {
        if (subscriptionController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.pinkAccent),
          );
        }

        return CustomScrollView(
          slivers: [
            // App Bar with gradient
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.pinkAccent.withOpacity(0.3),
                        const Color(0xFF0A0A0A),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.pinkAccent.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            size: 50,
                            color: Colors.pinkAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Subscription plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unlock premium features',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Current Plan Status (if not free)
                    if (subscriptionController.currentPlanId.value != 'free')
                      _buildCurrentPlanBanner(subscriptionController),
                    
                    const SizedBox(height: 24),

                    // Plans Grid
                    Row(
                      children: [
                        // Free Plan
                        Expanded(
                          child: _buildCompactPlanCard(
                            planId: 'free',
                            planName: 'Free',
                            price: 0,
                            duration: '',
                            features: const [
                              '10 swipes per day',
                            ],
                            isCurrentPlan: subscriptionController.currentPlanId.value == 'free',
                            isPremium: false,
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade800,
                                Colors.grey.shade900,
                              ],
                            ),
                            onTap: () {
                              _showPlanDetailsDialog(
                                context,
                                'Free',
                                const [
                                  '10 swipes per day',
                                ],
                                0,
                                true,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Plus Plan
                        Expanded(
                          child: _buildCompactPlanCard(
                            planId: 'plus',
                            planName: 'Plus',
                            price: 199000,
                            duration: '/month',
                            features: const [
                              '50 swipes per day',
                              'See who likes you',
                            ],
                            badge: 'Most popular',
                            isCurrentPlan: subscriptionController.currentPlanId.value == 'plus',
                            isPremium: false,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF6B9D),
                                Color(0xFFFF8FAB),
                              ],
                            ),
                            onTap: () {
                              if (subscriptionController.currentPlanId.value == 'plus') {
                                _showPlanDetailsDialog(
                                  context,
                                  'Plus',
                                  const [
                                    '50 swipes per day',
                                    'See who likes you',
                                    '5 Super Likes per month',
                                    'See who super liked you',
                                    'Priority support',
                                  ],
                                  199000,
                                  true,
                                );
                              } else {
                                _showPaymentMethodDialog(
                                  context,
                                  'plus',
                                  'Plus',
                                  199000,
                                  paymentController,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Premium Plan - Full Width & Highlighted
                    _buildPremiumPlanCard(
                      planId: 'premium',
                      planName: 'Premium',
                      price: 399000,
                      duration: '/month',
                      features: const [
                        'Unlimited swipes',
                        'See who likes you',
                        '10 Super Likes per month',
                        'See people blocked and unblocked',
                        'Priority support',
                        'Premium badge',
                      ],
                      isCurrentPlan: subscriptionController.currentPlanId.value == 'premium',
                      onTap: () {
                        if (subscriptionController.currentPlanId.value == 'premium') {
                          _showPlanDetailsDialog(
                            context,
                            'Premium',
                            const [
                              'Unlimited swipes',
                              'See who likes you',
                              '10 Super Likes per month',
                              'See people blocked and unblocked',
                              'Priority support',
                              'Premium badge',
                            ],
                            399000,
                            true,
                          );
                        } else {
                          _showPaymentMethodDialog(
                            context,
                            'premium',
                            'Premium',
                            399000,
                            paymentController,
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 32),

                    // Feature Comparison
                    _buildFeatureComparison(),

                    const SizedBox(height: 32),

                    // Transaction History Button
                    if (paymentController.hasPaymentHistory())
                      _buildTransactionHistoryButton(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCurrentPlanBanner(SubscriptionController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.greenAccent.withOpacity(0.2),
            Colors.greenAccent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.greenAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${controller.currentPlanName} Plan Active',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (controller.expiresOn.value != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Expires ${controller.getExpiryDateFormatted()} • ${controller.getDaysRemaining()} days left',
                    style: TextStyle(
                      color: controller.isExpiringSoon()
                          ? Colors.orangeAccent
                          : Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPlanCard({
    required String planId,
    required String planName,
    required int price,
    required String duration,
    required List<String> features,
    required bool isCurrentPlan,
    required bool isPremium,
    required Gradient gradient,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: isCurrentPlan ? null : gradient,
          color: isCurrentPlan ? Colors.white12 : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrentPlan
                ? Colors.greenAccent
                : Colors.white.withOpacity(0.1),
            width: isCurrentPlan ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    planName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isCurrentPlan)
                    const Text(
                      'Current',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: price == 0 ? 'Free' : '${_formatPrice(price)}đ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: duration,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  ...features.take(2).map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              color: Colors.white.withOpacity(0.9),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                f,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumPlanCard({
    required String planId,
    required String planName,
    required int price,
    required String duration,
    required List<String> features,
    required bool isCurrentPlan,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isCurrentPlan
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7C3AED),
                    Color(0xFFEC4899),
                  ],
                ),
          color: isCurrentPlan ? Colors.white12 : null,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCurrentPlan
                ? Colors.greenAccent
                : Colors.white.withOpacity(0.3),
            width: isCurrentPlan ? 2 : 2,
          ),
          boxShadow: isCurrentPlan
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isCurrentPlan
                    ? Colors.greenAccent
                    : Colors.white.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCurrentPlan ? Icons.check_circle : Icons.star,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCurrentPlan ? 'CURRENT PLAN' : 'BEST VALUE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Plan Name & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            planName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Everything you need',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_formatPrice(price)}đ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            duration,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Features Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3,
                    children: features.map((feature) {
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // CTA Button
                  if (!isCurrentPlan)
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onTap,
                          borderRadius: BorderRadius.circular(16),
                          child: const Center(
                            child: Text(
                              'Get Premium',
                              style: TextStyle(
                                color: Color(0xFF7C3AED),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Features Comparison',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Swipes
          _buildComparisonRow(
            'Daily Swipes',
            ['10', '50', 'Unlimited'],
          ),
          const Divider(color: Colors.white12, height: 24),
          
          // See who likes
          _buildComparisonRow(
            'See Who Likes You',
            ['✗', '✓', '✓'],
          ),
          const Divider(color: Colors.white12, height: 24),
          
          // Super Likes
          _buildComparisonRow(
            'Super Likes/Month',
            ['0', '5', '10'],
          ),
          const Divider(color: Colors.white12, height: 24),
          
          // See who super liked
          _buildComparisonRow(
            'See Who Super Liked',
            ['✗', '✓', '✓'],
          ),
          const Divider(color: Colors.white12, height: 24),
          
          // Priority support
          _buildComparisonRow(
            'Priority Support',
            ['✗', '✓', '✓'],
          ),
          const Divider(color: Colors.white12, height: 24),
          
          // See blocked
          _buildComparisonRow(
            'See Blocked/Unblocked',
            ['✗', '✗', '✓'],
          ),
          const Divider(color: Colors.white12, height: 24),
          
          // Premium badge
          _buildComparisonRow(
            'Premium Badge',
            ['✗', '✗', '✓'],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String feature, List<String> values) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            feature,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              values[0],
              style: TextStyle(
                color: values[0] == '✗' ? Colors.white24 : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              values[1],
              style: TextStyle(
                color: values[1] == '✗' ? Colors.white24 : const Color(0xFFFF6B9D),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              values[2],
              style: TextStyle(
                color: values[2] == '✗' ? Colors.white24 : const Color(0xFF7C3AED),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistoryButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/transaction-history'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.white70, size: 24),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Transaction History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showPlanDetailsDialog(
    BuildContext context,
    String planName,
    List<String> features,
    int price,
    bool isCurrentPlan,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          '$planName Plan',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (price > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${_formatPrice(price)}đ/month',
                  style: const TextStyle(
                    color: Colors.pinkAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Text(
              'Features:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentPlan ? Colors.greenAccent : Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isCurrentPlan ? 'Current Plan' : 'Close',
              style: TextStyle(
                color: isCurrentPlan ? Colors.black : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodDialog(
    BuildContext context,
    String planId,
    String planName,
    int amount,
    PaymentTransactionsController paymentController,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Choose Payment Method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$planName Plan • ${_formatPrice(amount)}đ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),

            // ZaloPay
            _buildPaymentMethodCard(
              icon: Icons.account_balance_wallet,
              title: 'ZaloPay',
              subtitle: 'Pay with ZaloPay wallet',
              gradient: const LinearGradient(
                colors: [Color(0xFF0088CC), Color(0xFF00AAF5)],
              ),
              onTap: () {
                Navigator.pop(context);
                _processPurchase(
                  context,
                  planId,
                  planName,
                  amount,
                  paymentController,
                  'zalopay',
                );
              },
            ),
            const SizedBox(height: 16),

            // VNPay
            _buildPaymentMethodCard(
              icon: Icons.credit_card,
              title: 'VNPay',
              subtitle: 'Pay via bank transfer',
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B00), Color(0xFFFF8800)],
              ),
              onTap: () {
                Navigator.pop(context);
                _processPurchase(
                  context,
                  planId,
                  planName,
                  amount,
                  paymentController,
                  'vnpay',
                );
              },
            ),
            const SizedBox(height: 24),

            // Cancel
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _processPurchase(
    BuildContext context,
    String planId,
    String planName,
    int amount,
    PaymentTransactionsController paymentController,
    String paymentMethod,
  ) async {
    final success = await paymentController.purchaseSubscription(
      context,
      planId,
      amount,
      paymentMethod: paymentMethod,
    );

    if (success) {
      // Show success animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Success!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$planName subscription activated',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Auto close after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    }
  }
}