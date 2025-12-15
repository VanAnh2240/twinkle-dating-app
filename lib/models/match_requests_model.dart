enum MatchRequestsStatus {none, pending, matched, unmatched}

class MatchRequestsModel {
  final String request_id;
  final String sender_id; 
  final String receiver_id;  
  final MatchRequestsStatus status; 
  final DateTime requested_on;

  MatchRequestsModel(
    {
      required this.request_id,
      required this.sender_id,
      required this.receiver_id,
      required this.status,
      required this.requested_on,
    }
  );

   /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'request_id': request_id,
      'sender_id': sender_id,
      'receiver_id': receiver_id,
      'status': status.name,
      'requested_on': requested_on.millisecondsSinceEpoch,
    };
  }

  /// Convert from Firestore map
  static MatchRequestsModel fromMap(Map<String, dynamic> map) {
    return MatchRequestsModel(
      request_id: map['id'] ?? '',
      sender_id: map['sender_id'] ?? '',
      receiver_id: map['receiver_id'] ?? '',
      status: MatchRequestsStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MatchRequestsStatus.none,
      ),
      requested_on: DateTime.fromMillisecondsSinceEpoch(map['requested_on'] ?? 0),
    );
  }
  
  MatchRequestsModel copyWith ({
    String? request_id,
    String? match_id,
    String? sender_id,
    String? receiver_id,
    MatchRequestsStatus? status,
    DateTime? requested_on,
  }) {
    return MatchRequestsModel(
      request_id: request_id ?? this.request_id,
      sender_id: sender_id ?? this.sender_id,
      receiver_id: receiver_id ?? this.receiver_id,
      status: this.status,
      requested_on: requested_on ?? this.requested_on
    );      
  }
}
