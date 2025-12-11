import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsModel {
  final String? user_id; 
  final String notification_text; 
  final DateTime sent_at;
  
  NotificationsModel(
    {
      this.user_id,
      required this.notification_text,
      required this.sent_at,
    }
  );

   /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'notification_text': notification_text,
      'sent_at': 
          sent_at != null ? Timestamp.fromDate(sent_at!) : null,
    };
  }

    /// Convert from Firestore map
  static NotificationsModel fromMap(Map<String, dynamic> map) {
    return NotificationsModel(
      user_id: map['user_id'] ?? '',
      notification_text: map['notification_text'] ?? '',
      sent_at: DateTime.fromMillisecondsSinceEpoch(map['sent_at'] ?? 0),
    );
  }
  
  NotificationsModel copyWith ({
    String? user_id,
    String? receiver_id,
    String? notification_text,
    DateTime? sent_at,
  }) {
    return NotificationsModel(
      user_id: user_id ?? this.user_id,
      notification_text: notification_text ?? this.notification_text,
      sent_at: sent_at ?? this.sent_at,
    );      
  }
}
