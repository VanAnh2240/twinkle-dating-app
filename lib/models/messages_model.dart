import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesModel {
  final String message_id;
  final String sender_id; 
  final String receiver_id;  
  final String message_text; 
  final DateTime sent_at;
  final bool is_read;
  
  MessagesModel(
    {
      required this.message_id,
      required this.sender_id,
      required this.receiver_id,
      required this.message_text,
      required this.sent_at,
      this.is_read = false,
    }
  );

   /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'message_id': message_id,
      'sender_id': sender_id,
      'receiver_id': receiver_id,
      'message_text': message_text,
      'sent_at': 
          sent_at != null ? Timestamp.fromDate(sent_at!) : null,
      'is_read': is_read, 
    };
  }

    /// Convert from Firestore map
  static MessagesModel fromMap(Map<String, dynamic> map) {
    return MessagesModel(
      message_id: map['message_id'] ?? '',
      sender_id: map['sender_id'] ?? '',
      receiver_id: map['receiver_id'] ?? '',
      message_text: map['message_text'] ?? '',
      sent_at: DateTime.fromMillisecondsSinceEpoch(map['sent_at'] ?? 0),
      is_read: map['is_read'] ?? false,
    );
  }
  
  MessagesModel copyWith ({
    String? message_id,
    String? sender_id,
    String? receiver_id,
    String? message_text,
    DateTime? sent_at,
    bool? is_read,
  }) {
    return MessagesModel(
      message_id: message_id ?? this.message_id,
      sender_id: sender_id ?? this.sender_id,
      receiver_id: receiver_id ?? this.receiver_id,
      message_text: message_text ?? this.message_text,
      sent_at: sent_at ?? this.sent_at,
      is_read: is_read ?? this.is_read,
    );      
  }
}
