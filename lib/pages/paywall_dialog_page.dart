// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// /// Paywall dialog that appears when user hits subscription limits
// /// Shows upgrade options and benefits of paid plans
// class PaywallDialogPage extends StatelessWidget {
//   final String featureName;
//   final String featureDescription;

//   const PaywallDialogPage({
//     Key? key,
//     required this.featureName,
//     required this.featureDescription,
//   }) : super(key: key);

//   /// Show paywall dialog
//   static void show({
//     required String featureName,
//     required String featureDescription,
//   }) {
//     Get.dialog(
//       PaywallDialogPage(
//         featureName: featureName,
//         featureDescription: featureDescription,
//       ),
//       barrierDismissible: true,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: Container(
//         constraints: BoxConstraints(maxWidth: 400),
//         decoration: BoxDecoration(
//           color: Color(0xFF1E1E1E),
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.5),
//               blurRadius: 20,
//               spreadRadius: 5,
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Close button
//             Align(
//               alignment: Alignment.topRight,
//               child: IconButton(
//                 icon: Icon(Icons.close, color: Colors.white70),
//                 onPressed: () => Get.back(),
//               ),
//             ),

//             // Lock icon
//             Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Color(0xFFFF6B9D).withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.lock,
//                 size: 48,
//                 color: Color(0xFFFF6B9D),
//               ),
//             ),

//             SizedBox(height: 24),

//             // Title
//             Text(
//               'Upgrade to $featureName',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),

//             SizedBox(height: 12),

//             // Description
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 32),
//               child: Text(
//                 featureDescription,
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 14,
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),

//             SizedBox(height: 32),

//             // Plan options
//             _buildPlanOption(
//               title: 'Plus',
//               price: '199,000 ₫/month',
//               features: [
//                 '50 swipes per day',
//                 'See who likes you',
//                 '5 Super Likes per month',
//                 'See who super liked you',
//                 'Priority support',
//               ],
//               color: Color(0xFF4CAF50),
//               onTap: () {
//                 Get.back();
//                 Get.toNamed('/subscription', arguments: 'plus');
//               },
//             ),

//             SizedBox(height: 16),

//             _buildPlanOption(
//               title: 'Premium',
//               price: '399,000 ₫/month',
//               features: [
//                 'Unlimited swipes',
//                 'See who likes you',
//                 '10 Super Likes per month',
//                 'See people blocked and unblocked',
//                 'Priority support',
//                 'Premium badge',
//               ],
//               color: Color(0xFFFF6B9D),
//               isRecommended: true,
//               onTap: () {
//                 Get.back();
//                 Get.toNamed('/subscription', arguments: 'premium');
//               },
//             ),

//             SizedBox(height: 32),

//             // Maybe later button
//             TextButton(
//               onPressed: () => Get.back(),
//               child: Text(
//                 'Maybe Later',
//                 style: TextStyle(
//                   color: Colors.white54,
//                   fontSize: 14,
//                 ),
//               ),
//             ),

//             SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlanOption({
//     required String title,
//     required String price,
//     required List<String> features,
//     required Color color,
//     required VoidCallback onTap,
//     bool isRecommended = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 24),
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Color(0xFF2A2A2A),
//           borderRadius: BorderRadius.circular(16),
//           border: isRecommended
//               ? Border.all(color: color, width: 2)
//               : null,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with badge
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       price,
//                       style: TextStyle(
//                         color: color,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (isRecommended)
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: color,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       'RECOMMENDED',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//               ],
//             ),

//             SizedBox(height: 16),

//             // Features list
//             ...features.map((feature) => Padding(
//                   padding: EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.check_circle,
//                         color: color,
//                         size: 16,
//                       ),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           feature,
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Helper function to show paywall for specific limits
// class PaywallHelper {
//   /// Show paywall when swipe limit is reached
//   static void showSwipeLimitReached(int currentPlan) {
//     PaywallDialog.show(
//       featureName: 'Unlimited Swipes',
//       featureDescription: 
//           'You\'ve reached your daily swipe limit. Upgrade to Plus or Premium to keep swiping!',
//     );
//   }

//   /// Show paywall when super like limit is reached
//   static void showSuperLikeLimitReached() {
//     PaywallDialog.show(
//       featureName: 'More Super Likes',
//       featureDescription: 
//           'You\'ve used all your Super Likes this month. Upgrade to Premium for 10 Super Likes per month!',
//     );
//   }

//   /// Show paywall for premium features
//   static void showPremiumFeature(String featureName) {
//     PaywallDialog.show(
//       featureName: featureName,
//       featureDescription: 
//           'This feature is only available for Premium members. Upgrade now to unlock!',
//     );
//   }

//   /// Show paywall for Plus features
//   static void showPlusFeature(String featureName) {
//     PaywallDialog.show(
//       featureName: featureName,
//       featureDescription: 
//           'This feature is available for Plus and Premium members. Upgrade to unlock!',
//     );
//   }

//   /// Show paywall for "See who liked you" feature
//   static void showSeeWhoLikedYou() {
//     PaywallDialog.show(
//       featureName: 'See Who Likes You',
//       featureDescription: 
//           'Curious who\'s interested? Upgrade to Plus or Premium to see everyone who liked you!',
//     );
//   }

//   /// Show paywall for "See who super liked you" feature
//   static void showSeeWhoSuperLikedYou() {
//     PaywallDialog.show(
//       featureName: 'See Who Super Liked You',
//       featureDescription: 
//           'Someone is really interested! Upgrade to see who super liked you.',
//     );
//   }

//   /// Show paywall for blocked people feature
//   static void showBlockedPeopleFeature() {
//     PaywallDialog.show(
//       featureName: 'Manage Blocked People',
//       featureDescription: 
//           'View and manage your blocked list with Premium membership.',
//     );
//   }
// }