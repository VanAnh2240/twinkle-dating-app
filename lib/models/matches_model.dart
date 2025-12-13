import 'package:cloud_firestore/cloud_firestore.dart';

class MatchesModel { 
  final String match_id;
  final String user1_id; 
  final String user2_id;  
  final DateTime matched_at;
  
  MatchesModel(
    {
      required this.match_id,
      required this.user1_id,
      required this.user2_id,
      required this.matched_at,
    }
  );

   /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'match_id': match_id,
      'user1_id': user1_id,
      'user2_id': user2_id,
      'matched_at': 
          matched_at != null ? Timestamp.fromDate(matched_at!) : null,
    };
  }

    /// Convert from Firestore map
  static MatchesModel fromMap(Map<String, dynamic> map) {
    return MatchesModel(
      match_id: map['match_id'] ?? '',
      user1_id: map['user1_id'] ?? '',
      user2_id: map['user2_id'] ?? '',
      matched_at: DateTime.fromMillisecondsSinceEpoch(map['matched_at'] ?? 0),
    );
  }
  
  MatchesModel copyWith ({
    String? match_id,
    String? user1_id,
    String? user2_id,
    DateTime? matched_at,
  }) {
    return MatchesModel(
      match_id: match_id ?? this.match_id,
      user1_id: user1_id ?? this.user1_id,
      user2_id: user2_id ?? this.user2_id,
      matched_at: matched_at ?? this.matched_at
    );      
  }

  String getOtherUsersId(String currentUserId) {
    return user1_id != currentUserId ? user1_id! : user2_id!;
  }
}
