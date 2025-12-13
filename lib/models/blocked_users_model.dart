import 'package:cloud_firestore/cloud_firestore.dart';

class BlockedUsersModel { 
  final String block_id;
  final String user_id; 
  final String blocked_user_id;  
  final DateTime blocked_on;
  
  BlockedUsersModel({
    required this.block_id,
    required this.user_id,
    required this.blocked_user_id,
    required this.blocked_on,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'block_id': block_id,
      'user_id': user_id,
      'blocked_user_id': blocked_user_id,
      'blocked_on': Timestamp.fromDate(blocked_on),
    };
  }

  /// Convert from Firestore map
  factory BlockedUsersModel.fromMap(Map<String, dynamic> map) {
    return BlockedUsersModel(
      block_id: map['block_id'] ?? '',
      user_id: map['user_id'] ?? '',
      blocked_user_id: map['blocked_user_id'] ?? '',
      blocked_on: map['blocked_on'] is Timestamp
          ? (map['blocked_on'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Copy with
  BlockedUsersModel copyWith({
    String? block_id,
    String? user_id,
    String? blocked_user_id,
    DateTime? blocked_on,
  }) {
    return BlockedUsersModel(
      block_id: block_id ?? this.block_id,
      user_id: user_id ?? this.user_id,
      blocked_user_id: blocked_user_id ?? this.blocked_user_id,
      blocked_on: blocked_on ?? this.blocked_on,
    );
  }

  /// Get other user ID 
  String getOtherUsersId(String currentUserId) {
    return user_id == currentUserId ? blocked_user_id : user_id;
  }
}
