import 'package:cloud_firestore/cloud_firestore.dart';

class UserSubscriptionsModel {
  final String subscription_id;
  final String user_id;
  final String plan_id;
  final DateTime subscribed_on;
  final DateTime expires_on;

  UserSubscriptionsModel({
    required this.subscription_id,
    required this.user_id,
    required this.plan_id,
    required this.subscribed_on,
    required this.expires_on,
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
      // Try parse as int first (milliseconds)
      final intValue = int.tryParse(value);
      if (intValue != null) {
        return DateTime.fromMillisecondsSinceEpoch(intValue);
      }
      // Try parse as ISO string
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
      'subscription_id': subscription_id,
      'user_id': user_id,
      'plan_id': plan_id,
      'subscribed_on': subscribed_on.millisecondsSinceEpoch,
      'expires_on': expires_on.millisecondsSinceEpoch,
    };
  }

  /// Convert from Firestore map
  static UserSubscriptionsModel fromMap(Map<String, dynamic> map) {
    return UserSubscriptionsModel(
      subscription_id: map['subscription_id'] ?? '',
      user_id: map['user_id'] ?? '',
      plan_id: map['plan_id'] ?? '',
      subscribed_on: _parseDateTime(map['subscribed_on']),
      expires_on: _parseDateTime(map['expires_on']),
    );
  }

  UserSubscriptionsModel copyWith({
    String? subscription_id,
    String? user_id,
    String? plan_id,
    DateTime? subscribed_on,
    DateTime? expires_on,
  }) {
    return UserSubscriptionsModel(
      subscription_id: subscription_id ?? this.subscription_id,
      user_id: user_id ?? this.user_id,
      plan_id: plan_id ?? this.plan_id,
      subscribed_on: subscribed_on ?? this.subscribed_on,
      expires_on: expires_on ?? this.expires_on,
    );
  }
}