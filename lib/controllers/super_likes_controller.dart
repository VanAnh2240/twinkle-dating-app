// // lib/controllers/super_like_controller.dart
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:twinkle/controllers/subscriptions_controller.dart';

// class SuperLikeController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final SubscriptionController _subscriptionController = Get.find<SubscriptionController>();

//   final RxInt monthlyUsedCount = 0.obs;
//   final RxInt monthlyLimit = SubscriptionConstants.premiumSuperLikeLimit.obs;
//   final RxBool isLoading = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _loadMonthlySuperLikes();
//   }

//   /// Load super likes count for current month
//   Future<void> _loadMonthlySuperLikes() async {
//     isLoading.value = true;
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return;

//       final now = DateTime.now();
//       final startOfMonth = DateTime(now.year, now.month, 1);
//       final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

//       final snapshot = await _firestore
//           .collection(FirestoreConstants.superLikesCollection)
//           .where('sender_id', isEqualTo: userId)
//           .where('super_liked_on', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
//           .where('super_liked_on', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
//           .get();

//       monthlyUsedCount.value = snapshot.docs.length;
//     } catch (e) {
//       print('Error loading super likes: $e');
//       monthlyUsedCount.value = 0;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Check if user can send super like
//   bool canSendSuperLike() {
//     // Must be Premium subscriber
//     if (!_subscriptionController.canSuperLike()) {
//       return false;
//     }

//     // Check monthly limit
//     return monthlyUsedCount.value < monthlyLimit.value;
//   }

//   /// Get remaining super likes for this month
//   int getRemainingSuperLikes() {
//     if (!_subscriptionController.isPremium.value) return 0;
//     final remaining = monthlyLimit.value - monthlyUsedCount.value;
//     return remaining > 0 ? remaining : 0;
//   }

//   /// Send a super like
//   Future<bool> sendSuperLike(String receiverId) async {
//     try {
//       // Check permissions
//       if (!canSendSuperLike()) {
//         Get.snackbar(
//           'Limit Reached',
//           'You have used all your Super Likes for this month',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return false;
//       }

//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return false;

//       // Check if already super liked this user
//       final existingLike = await _firestore
//           .collection(FirestoreConstants.superLikesCollection)
//           .where('sender_id', isEqualTo: userId)
//           .where('receiver_id', isEqualTo: receiverId)
//           .get();

//       if (existingLike.docs.isNotEmpty) {
//         Get.snackbar(
//           'Already Super Liked',
//           'You have already sent a Super Like to this user',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return false;
//       }

//       // Create super like
//       final superLikeRef = _firestore
//           .collection(FirestoreConstants.superLikesCollection)
//           .doc();

//       final superLike = SuperLikeModel(
//         superLikeId: superLikeRef.id,
//         senderId: userId,
//         receiverId: receiverId,
//         superLikedOn: DateTime.now(),
//       );

//       await superLikeRef.set(superLike.toFirestore());

//       // Update local count
//       monthlyUsedCount.value++;

//       Get.snackbar(
//         'Super Like Sent!',
//         'Your Super Like has been sent successfully',
//         snackPosition: SnackPosition.BOTTOM,
//       );

//       return true;
//     } catch (e) {
//       print('Error sending super like: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to send Super Like',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return false;
//     }
//   }

//   /// Get super like progress percentage
//   double getSuperLikeProgress() {
//     if (monthlyLimit.value == 0) return 0.0;
//     return (monthlyUsedCount.value / monthlyLimit.value * 100).clamp(0.0, 100.0);
//   }

//   /// Check if limit is reached
//   bool isLimitReached() {
//     return monthlyUsedCount.value >= monthlyLimit.value;
//   }

//   /// Refresh super like data
//   Future<void> refreshSuperLikeData() async {
//     await _loadMonthlySuperLikes();
//   }

//   /// Check if user has super liked a specific user
//   Future<bool> hasSuperLiked(String receiverId) async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return false;

//       final snapshot = await _firestore
//           .collection('SuperLikes')
//           .where('sender_id', isEqualTo: userId)
//           .where('receiver_id', isEqualTo: receiverId)
//           .limit(1)
//           .get();

//       return snapshot.docs.isNotEmpty;
//     } catch (e) {
//       print('Error checking super like: $e');
//       return false;
//     }
//   }
// }