import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsModel {
  final String notification_id;
  final String user_id;
  final String notification_text;
  final DateTime sent_at;
  final bool is_read;

  NotificationsModel({
    required this.notification_id,
    required this.user_id,
    required this.notification_text,
    required this.sent_at,
    this.is_read = false,
  });

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is String) {
      final intValue = int.tryParse(value);
      if (intValue != null) {
        return DateTime.fromMillisecondsSinceEpoch(intValue);
      }
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Failed to parse datetime string: $value');
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'notification_id': notification_id,
      'user_id': user_id,
      'notification_text': notification_text,
      'sent_at': sent_at.millisecondsSinceEpoch,
      'is_read': is_read,
    };
  }

  /// Convert from Firestore map
  static NotificationsModel fromMap(Map<String, dynamic> map) {
    return NotificationsModel(
      notification_id: map['notification_id'] ?? '',
      user_id: map['user_id'] ?? '',
      notification_text: map['notification_text'] ?? '',
      sent_at: _parseDateTime(map['sent_at']),
      is_read: map['is_read'] ?? false,
    );
  }

  NotificationsModel copyWith({
    String? notification_id,
    String? user_id,
    String? notification_text,
    DateTime? sent_at,
    bool? is_read,
  }) {
    return NotificationsModel(
      notification_id: notification_id ?? this.notification_id,
      user_id: user_id ?? this.user_id,
      notification_text: notification_text ?? this.notification_text,
      sent_at: sent_at ?? this.sent_at,
      is_read: is_read ?? this.is_read,
    );
  }
}