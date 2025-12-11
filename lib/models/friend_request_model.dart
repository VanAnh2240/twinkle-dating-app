import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestsModel {
  final String? sender_id; 
  final String? receiver_id;  
  final String status; 
  final DateTime requested_on;
  
  FriendRequestsModel(
    {
      this.sender_id,
      this.receiver_id,
      required this.status,
      required this.requested_on,
    }
  );

   /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'sender_id': sender_id,
      'receiver_id': receiver_id,
      'status': status,
      'requested_on': 
          requested_on != null ? Timestamp.fromDate(requested_on!) : null,
    };
  }

    /// Convert from Firestore map
  static FriendRequestsModel fromMap(Map<String, dynamic> map) {
    return FriendRequestsModel(
      sender_id: map['sender_id'] ?? '',
      receiver_id: map['receiver_id'] ?? '',
      status: map['status'] ?? '',
      requested_on: DateTime.fromMillisecondsSinceEpoch(map['requested_on'] ?? 0),
    );
  }
  
  FriendRequestsModel copyWith ({
    String? match_id,
    String? sender_id,
    String? receiver_id,
    String? status,
    DateTime? requested_on,
  }) {
    return FriendRequestsModel(
      sender_id: sender_id ?? this.sender_id,
      receiver_id: receiver_id ?? this.receiver_id,
      status: this.status,
      requested_on: requested_on ?? this.requested_on
    );      
  }
}
