import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentTransactionsModel {
  final String transaction_id;
  final String user_id;
  final double amount;
  final DateTime transaction_date;
  final String payment_method; // vnpay | zalopay
  final String status; // 'pending', 'success', 'failed', 'cancelled'

  PaymentTransactionsModel({
    required this.transaction_id,
    required this.user_id,
    required this.amount,
    required this.transaction_date,
    required this.payment_method,
    required this.status,
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
      'transaction_id': transaction_id,
      'user_id': user_id,
      'amount': amount,
      'transaction_date': transaction_date.millisecondsSinceEpoch,
      'payment_method': payment_method,
      'status': status,
    };
  }

  /// Convert from Firestore map
  static PaymentTransactionsModel fromMap(Map<String, dynamic> map) {
    return PaymentTransactionsModel(
      transaction_id: map['transaction_id'] ?? '',
      user_id: map['user_id'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      transaction_date: _parseDateTime(map['transaction_date']),
      payment_method: map['payment_method'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }

  PaymentTransactionsModel copyWith({
    String? transaction_id,
    String? user_id,
    double? amount,
    DateTime? transaction_date, 
    String? payment_method,
    String? status,
  }) {
    return PaymentTransactionsModel(
      transaction_id: transaction_id ?? this.transaction_id,
      user_id: user_id ?? this.user_id,
      amount: amount ?? this.amount,
      transaction_date: transaction_date ?? this.transaction_date,
      payment_method: payment_method ?? this.payment_method,
      status: status ?? this.status,
    );
  }
}