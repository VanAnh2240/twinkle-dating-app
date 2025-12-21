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
    final selectedPlanId = 'premium'.obs; // Default selected plan

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
            // Compact App Bar
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFF0A0A0A),
              elevation: 0,
              title: const Text(
                'Subscription',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                if (paymentController.hasPaymentHistory())
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white70),
                    onPressed: () => Get.toNamed('/transaction-history'),
                  ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Plan & Features Section (Highlighted)
                    if (subscriptionController.currentPlanId.value != 'free')
                      _buildActivePlanSection(subscriptionController)
                    else
                      _buildFreeUserPromoBanner(),
                    
                    const SizedBox(height: 32),

                    // Section Title
                    const Text(
                      'Choose Your Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap on a plan to see features',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Horizontal Scrollable Plans
                    _buildHorizontalPlansScroll(subscriptionController, paymentController, selectedPlanId),

                    const SizedBox(height: 24),

                    // Selected Plan Features Section
                    _buildSelectedPlanFeatures(subscriptionController, paymentController, selectedPlanId),

                    const SizedBox(height: 32),

                    // Feature Comparison Section
                    _buildFeatureComparisonSection(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Horizontal Scrollable Plans
  Widget _buildHorizontalPlansScroll(
    SubscriptionController subscriptionController,
    PaymentTransactionsController paymentController,
    RxString selectedPlanId,
  ) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // Premium Plan
          _buildScrollablePlanCard(
            planId: 'premium',
            planName: 'Premium',
            price: 399000,
            badge: 'BEST VALUE',
            icon: Icons.diamond,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromARGB(255, 188, 44, 216), Color(0xFFEC4899)],
            ),
            isCurrentPlan: subscriptionController.currentPlanId.value == 'premium',
            selectedPlanId: selectedPlanId,
          ),
          const SizedBox(width: 16),
          
          // Plus Plan
          _buildScrollablePlanCard(
            planId: 'plus',
            planName: 'Plus',
            price: 199000,
            badge: 'POPULAR',
            icon: Icons.star,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromARGB(255, 249, 96, 147), Color.fromARGB(255, 255, 113, 149)],
            ),
            isCurrentPlan: subscriptionController.currentPlanId.value == 'plus',
            selectedPlanId: selectedPlanId,
          ),
          const SizedBox(width: 16),
          
          // Free Plan
          _buildScrollablePlanCard(
            planId: 'free',
            planName: 'Free',
            price: 0,
            icon: Icons.favorite_outline,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey.shade700, Colors.grey.shade800],
            ),
            isCurrentPlan: subscriptionController.currentPlanId.value == 'free',
            selectedPlanId: selectedPlanId,
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildScrollablePlanCard({
    required String planId,
    required String planName,
    required int price,
    String? badge,
    required IconData icon,
    required Gradient gradient,
    required bool isCurrentPlan,
    required RxString selectedPlanId,
  }) {
    return Obx(() {
      final isSelected = selectedPlanId.value == planId;
      
      return GestureDetector(
        onTap: () => selectedPlanId.value = planId,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 160,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : isCurrentPlan
                      ? Colors.greenAccent
                      : Colors.white.withOpacity(0.2),
              width: isSelected ? 3 : isCurrentPlan ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                if (badge != null && !isCurrentPlan)
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
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ACTIVE', 
                      style: TextStyle( 
                        color: Colors.black, 
                        fontSize: 8, 
                        fontWeight: FontWeight.bold,
                      )
                    ),
                ),


                const Spacer(),
                
                // Icon
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                
                // Plan Name
                Text(
                  planName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Price
                if (price > 0)
                  Text(
                    '${_formatPrice(price)}đ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    'Free',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSelectedPlanFeatures(
    SubscriptionController subscriptionController,
    PaymentTransactionsController paymentController,
    RxString selectedPlanId,
  ) {
    return Obx(() {
      final planId = selectedPlanId.value;
      final isCurrentPlan = subscriptionController.currentPlanId.value == planId;
      
      String planName;
      int price;
      List<String> features;
      Color accentColor;
      
      switch (planId) {
        case 'premium':
          planName = 'Premium';
          price = 399000;
          features = [
            'Unlimited swipes',
            'See who likes you',
            '10 Super Likes per month',
            'See people blocked'
            'Unblocked',
            'Priority support',
            'Premium badge',
          ];
          accentColor = const Color(0xFF7C3AED);
          break;
        case 'plus':
          planName = 'Plus';
          price = 199000;
          features = [
            '50 swipes per day',
            'See who likes you',
            '5 Super Likes per month',
            'See who super liked you',
            'Priority support',
          ];
          accentColor = const Color(0xFFFF6B9D);
          break;
        default:
          planName = 'Free';
          price = 0;
          features = [
            '10 swipes per day',
          ];
          accentColor = Colors.grey.shade600;
      }
      
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(planId),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accentColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isCurrentPlan)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Your current plan',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (price > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_formatPrice(price)}đ',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'per month',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Features
              const Text(
                'Features',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: accentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              
              const SizedBox(height: 20),
              
              // CTA Button
              if (!isCurrentPlan && price > 0)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showPaymentMethodDialog(
                        Get.context!,
                        planId,
                        planName,
                        price,
                        paymentController,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Subscribe to $planName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  // Active Plan Section with Your Features
  Widget _buildActivePlanSection(SubscriptionController controller) {
    final isPremium = controller.currentPlanId.value == 'premium';
    final planColor = isPremium ? const Color(0xFF7C3AED) : const Color(0xFFFF6B9D);
    
    final features = controller.currentPlanId.value == 'premium'
        ? [
            'Unlimited swipes',
            'See who likes you',
            '10 Super Likes per month',
            'See people blocked',
            'Unblocked',
            'Priority support',
            'Premium badge',
          ]
        : [
            '50 swipes per day',
            'See who likes you',
            '5 Super Likes per month',
            'See who super liked you',
            'Priority support',
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            planColor.withOpacity(0.25),
            planColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: planColor.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: planColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Plan Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [planColor, planColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: planColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPremium ? Icons.diamond : Icons.star,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Plan Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            controller.currentPlanName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.black,                              
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(
                        'Your current subscription',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Expiry Info
          if (controller.expiresOn.value != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: controller.isExpiringSoon()
                        ? Colors.orangeAccent
                        : Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expires ${controller.getExpiryDateFormatted()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${controller.getDaysRemaining()} days remaining',
                          style: TextStyle(
                            color: controller.isExpiringSoon()
                                ? Colors.orangeAccent
                                : Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (controller.isExpiringSoon())
                    TextButton(
                      onPressed: () {
                        // Renew action
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Renew',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Features Section - HIGHLIGHTED
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: planColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Features',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Features Grid
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: features.map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: planColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: planColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: planColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            feature,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Free User Promo Banner
  Widget _buildFreeUserPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C3AED),
            Color(0xFFEC4899),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Upgrade to Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock unlimited swipes and exclusive features',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Feature Comparison Section
  Widget _buildFeatureComparisonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Compare Plans',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header Row
              _buildComparisonHeader(),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 16),
              
              // Comparison Rows
              _buildComparisonRow('Daily Swipes', ['10', '50', 'Unlimited']),
              _buildComparisonRow('See Who Likes You', ['✗', '✓', '✓']),
              _buildComparisonRow('Super Likes/Month', ['0', '5', '10']),
              _buildComparisonRow('See Who Super Liked', ['✗', '✓', '✓']),
              _buildComparisonRow('Priority Support', ['✗', '✓', '✓']),
              _buildComparisonRow('See Blocked/Unblocked', ['✗', '✗', '✓']),
              _buildComparisonRow('Premium Badge', ['✗', '✗', '✓']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonHeader() {
    return Row(
      children: [
        const Expanded(
          flex: 2,
          child: Text(
            'Features',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Free',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Plus',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color.fromARGB(255, 252, 109, 157),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Premium',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF7C3AED),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(String feature, List<String> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: _buildComparisonValue(values[0], Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Center(
              child: _buildComparisonValue(values[1], const Color(0xFFFF6B9D)),
            ),
          ),
          Expanded(
            child: Center(
              child: _buildComparisonValue(values[2], const Color(0xFF7C3AED)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonValue(String value, Color color) {
    if (value == '✗') {
      return Icon(
        Icons.close,
        color: Colors.white24,
        size: 16,
      );
    } else if (value == '✓') {
      return Icon(
        Icons.check_circle,
        color: color,
        size: 16,
      );
    } else {
      return Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showAlreadySubscribedDialog(BuildContext context, String planName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
            const SizedBox(width: 12),
            Text(
              'Active Plan',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'You are currently subscribed to the $planName plan. Enjoy all the premium features!',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanDetailsDialog(
    BuildContext context,
    String planName,
    List<String> features,
    int price,
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Colors.pinkAccent,
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
      // Show success animation with confetti effect
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black87,
        builder: (context) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(40),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        planId == 'premium'
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFFFF6B9D),
                        planId == 'premium'
                            ? const Color(0xFFEC4899)
                            : const Color(0xFFFF8FAB),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: (planId == 'premium'
                                ? const Color(0xFF7C3AED)
                                : const Color(0xFFFF6B9D))
                            .withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated checkmark
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, checkValue, child) {
                          return Transform.scale(
                            scale: checkValue,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: planId == 'premium'
                                    ? const Color(0xFF7C3AED)
                                    : const Color(0xFFFF6B9D),
                                size: 64,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Success text
                      const Text(
                        '🎉 Congratulations! 🎉',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Text(
                        'Your $planName subscription',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'has been activated successfully!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Features unlocked
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Features Unlocked',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildFeaturePill('✨ Premium Access'),
                                _buildFeaturePill('💎 All Features'),
                                _buildFeaturePill('🚀 Priority Support'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Enjoy button
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOut,
                        builder: (context, buttonValue, child) {
                          return Opacity(
                            opacity: buttonValue,
                            child: child,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'Start Enjoying!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: planId == 'premium'
                                        ? const Color(0xFF7C3AED)
                                        : const Color(0xFFFF6B9D),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Auto close after 4 seconds
      await Future.delayed(const Duration(seconds: 4));
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildFeaturePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}