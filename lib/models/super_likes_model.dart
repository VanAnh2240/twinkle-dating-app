class SuperLikesModel {
  final String super_like_id;
  final String sender_id; 
  final String receiver_id;   
  final DateTime super_liked_on;

  SuperLikesModel(
    {
      required this.super_like_id,
      required this.sender_id,
      required this.receiver_id,
      required this.super_liked_on,
    }
  );

   /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'super_like_id': super_like_id,
      'sender_id': sender_id,
      'receiver_id': receiver_id,
      'super_liked_on': super_liked_on.millisecondsSinceEpoch,
    };
  }

  /// Convert from Firestore map
  static SuperLikesModel fromMap(Map<String, dynamic> map) {
    return SuperLikesModel(
      super_like_id: map['id'] ?? '',
      sender_id: map['sender_id'] ?? '',
      receiver_id: map['receiver_id'] ?? '',
      super_liked_on: DateTime.fromMillisecondsSinceEpoch(map['super_liked_on'] ?? 0),
    );
  }
  
  SuperLikesModel copyWith ({
    String? super_like_id,
    String? match_id,
    String? sender_id,
    String? receiver_id,
    DateTime? super_liked_on,
  }) {
    return SuperLikesModel(
      super_like_id: super_like_id ?? this.super_like_id,
      sender_id: sender_id ?? this.sender_id,
      receiver_id: receiver_id ?? this.receiver_id,
      super_liked_on: super_liked_on ?? this.super_liked_on
    );      
  }
}
