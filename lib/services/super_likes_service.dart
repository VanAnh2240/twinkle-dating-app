// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:twinkle/controllers/subscriptions_controller.dart';

// /// Service for handling Super Like operations
// /// Only available to Premium users with 5 per month limit
// class SuperLikeService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   /// Send a super like to another user
//   /// Returns true if successful, false if limit exceeded or not allowed
//   Future<bool> sendSuperLike(String receiverId) async {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) return false;

//     // Check if user can send super like
//     final subscriptionController = Get.find<SubscriptionController>();
//     final canSend = await subscriptionController.canSendSuperLike();

//     if (!canSend) {
//       return false; // Not premium or limit exceeded
//     }

//     try {
//       // Check if already super liked this user
//       final existingSuperLike = await _firestore
//           .collection('SuperLikes')
//           .where('sender_id', isEqualTo: userId)
//           .where('receiver_id', isEqualTo: receiverId)
//           .limit(1)
//           .get();

//       if (existingSuperLike.docs.isNotEmpty) {
//         Get.snackbar(
//           'Already Sent',
//           'You have already super liked this user',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return false;
//       }

//       // Create super like document
//       final superLikeRef = _firestore.collection('SuperLikes').doc();
//       await superLikeRef.set({
//         'super_like_id': superLikeRef.id,
//         'sender_id': userId,
//         'receiver_id': receiverId,
//         'super_liked_on': FieldValue.serverTimestamp(),
//       });

//       // Optionally: Create a notification for the receiver
//       await _createSuperLikeNotification(receiverId, userId);

//       Get.snackbar(
//         'Super Like Sent! ⭐',
//         'Your super like has been sent successfully',
//         snackPosition: SnackPosition.BOTTOM,
//         duration: const Duration(seconds: 2),
//       );

//       return true;
//     } catch (e) {
//       print('Error sending super like: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to send super like',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return false;
//     }
//   }

//   /// Get super likes sent this month
//   Future<int> getMonthSuperLikeCount() async {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) return 0;

//     try {
//       final now = DateTime.now();
//       final firstDayOfMonth = DateTime(now.year, now.month, 1);
      
//       final snapshot = await _firestore
//           .collection('SuperLikes')
//           .where('sender_id', isEqualTo: userId)
//           .where('super_liked_on', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
//           .get();

//       return snapshot.docs.length;
//     } catch (e) {
//       print('Error getting super like count: $e');
//       return 0;
//     }
//   }

//   /// Get list of users who super liked current user
//   Future<List<Map<String, dynamic>>> getReceivedSuperLikes() async {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) return [];

//     try {
//       final snapshot = await _firestore
//           .collection('SuperLikes')
//           .where('receiver_id', isEqualTo: userId)
//           .orderBy('super_liked_on', descending: true)
//           .get();

//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         return {
//           'super_like_id': doc.id,
//           'sender_id': data['sender_id'],
//           'super_liked_on': (data['super_liked_on'] as Timestamp).toDate(),
//         };
//       }).toList();
//     } catch (e) {
//       print('Error getting received super likes: $e');
//       return [];
//     }
//   }

//   /// Check if user has super liked another user
//   Future<bool> hasSuperLiked(String receiverId) async {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) return false;

//     try {
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

//   /// Get super like history
//   Future<List<Map<String, dynamic>>> getSuperLikeHistory() async {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) return [];

//     try {
//       final snapshot = await _firestore
//           .collection('SuperLikes')
//           .where('sender_id', isEqualTo: userId)
//           .orderBy('super_liked_on', descending: true)
//           .get();

//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         return {
//           'super_like_id': doc.id,
//           'receiver_id': data['receiver_id'],
//           'super_liked_on': (data['super_liked_on'] as Timestamp).toDate(),
//         };
//       }).toList();
//     } catch (e) {
//       print('Error getting super like history: $e');
//       return [];
//     }
//   }

//   /// Create notification for super like (optional implementation)
//   Future<void> _createSuperLikeNotification(String receiverId, String senderId) async {
//     try {
//       final notificationRef = _firestore.collection('Notifications').doc();
//       await notificationRef.set({
//         'notification_id': notificationRef.id,
//         'user_id': receiverId,
//         'type': 'super_like',
//         'sender_id': senderId,
//         'message': 'You received a Super Like! ⭐',
//         'created_at': FieldValue.serverTimestamp(),
//         'read': false,
//       });
//     } catch (e) {
//       print('Error creating notification: $e');
//     }
//   }
// }