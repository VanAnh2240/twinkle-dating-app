import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesModel {
  final String? sender_id; 
  final String? receiver_id;  
  final String message_text; 
  final DateTime sent_at;
  
  MessagesModel(
    {
      this.sender_id,
      this.receiver_id,
      required this.message_text,
      required this.sent_at,
    }
  );

   /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'sender_id': sender_id,
      'receiver_id': receiver_id,
      'message_text': message_text,
      'sent_at': 
          sent_at != null ? Timestamp.fromDate(sent_at!) : null,
    };
  }

    /// Convert from Firestore map
  static MessagesModel fromMap(Map<String, dynamic> map) {
    return MessagesModel(
      sender_id: map['sender_id'] ?? '',
      receiver_id: map['receiver_id'] ?? '',
      message_text: map['message_text'] ?? '',
      sent_at: DateTime.fromMillisecondsSinceEpoch(map['sent_at'] ?? 0),
    );
  }
  
  MessagesModel copyWith ({
    String? sender_id,
    String? receiver_id,
    String? message_text,
    DateTime? sent_at,
  }) {
    return MessagesModel(
      sender_id: sender_id ?? this.sender_id,
      receiver_id: receiver_id ?? this.receiver_id,
      message_text: message_text ?? this.message_text,
      sent_at: sent_at ?? this.sent_at,
    );      
  }
}
