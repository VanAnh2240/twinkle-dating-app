// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:twinkle/models/messages_model.dart';

// class ChatService {

//   // get instance of firebase  & auth
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;


//   //get user stream
//  Stream<List<Map<String,dynamic>>> getUsersStream() {
//     return _firestore.collection("Users").snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         //go though each individual user
//         final user = doc.data();

//         //return user
//         return user;
//       }).toList();
//     });

//   }

  
//   // send messages
//   Future<void> sendMessage(String receiverID, message) async {
//     //get current user info
//     final String currentUserID = _auth.currentUser!.uid;
//     final String currentUserEmail = _auth.currentUser!.email!;
//     final Timestamp timestamp = Timestamp.now();

//     //create a new message
//     Messages newMessage = Messages(
//       sender_id: currentUserID,
//       receiver_id: receiverID,
//       message_text: message,
//       sent_at: timestamp,
//     );


//     //chat room ID for 2 users
//     List<String> ids = [currentUserID , receiverID];
//     ids.sort(); //sort the ids (to ensure the chatroomID is the same for any 2 people)
//     String chatRoomID = ids.join('_');


//     //add new message to database
//     await _firestore
//     .collection("chat_rooms")
//     .doc(chatRoomID)
//     .collection("messages")
//     .add(newMessage.toMap());

//   }

//   //get messages
//   Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
//     //contruct a chat room ID for the 2 users
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     return _firestore
//     .collection("chat_rooms")
//     .doc(chatRoomID)
//     .collection("messages")
//     .orderBy("timestamp", descending: false)
//     .snapshots();
//   }
// }