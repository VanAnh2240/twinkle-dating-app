import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twinkle/models/messages_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String chatRoomID, String receiverID, String text) async {
    DocumentSnapshot room =
        await _firestore.collection("ChatRooms").doc(chatRoomID).get();

    if (!(room.data() as Map)["is_active"]) {
      throw Exception("This chat room is inactive (unmatched).");
    }

    String senderID = FirebaseAuth.instance.currentUser!.uid;

    MessagesModel msg = MessagesModel(
      sender_id: senderID,
      receiver_id: receiverID,
      message_text: text,
      sent_at: DateTime.now(),
    );

    await _firestore
        .collection("ChatRooms")
        .doc(chatRoomID)
        .collection("Messages")
        .add(msg.toMap());

    // Update last message
    await _firestore.collection("ChatRooms").doc(chatRoomID).update({
      "last_message": text,
      "last_message_time": DateTime.now(),
    });
  }

  Stream<List<MessagesModel>> getMessages(String chatRoomID) {
    return _firestore
      .collection("ChatRooms")
      .doc(chatRoomID)
      .collection("Messages")
      .orderBy("sent_at", descending: false)
      .snapshots()
      .map((query) =>
          query.docs.map((e) => MessagesModel.fromMap(e.data())).toList());
  }
}
