// import 'package:cloud_firestore/cloud_firestore.dart';

// class Messages {
//   final int message_id;
//   final int sender_id;
//   final int receiver_id;
//   final int message_text;
//   final Timestamp sent_at;

//   Messages ({
//     required this.sender_id,
//     required this.receiver_id,
//     required this.message_text,
//     required this.sent_at,
//   });

//   //covert to a map
//   Map<String,dynamic> toMap() {
//     return {
//       'sender_id': sender_id,
//       'receiver_id' : receiver_id,
//       'message_text': message_text,
//       'sent_at': sent_at,
//     };
//   }


// }