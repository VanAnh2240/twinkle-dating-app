import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsModel {
  final String chat_id;
  final bool is_enable;
  final List<String> participants;

  final String? last_message;
  final DateTime? last_message_time;
  final String? last_message_sender_id;

  final Map<String, int> unread_count;
  final Map<String, bool> delete_by;
  final Map<String, DateTime?> delete_at;
  final Map<String, DateTime?> last_seen_by;

  final DateTime created_at;
  final DateTime updated_at;

  ChatsModel({
    required this.chat_id,
    required this.is_enable,
    required this.participants,

    this.last_message,
    this.last_message_time,
    this.last_message_sender_id,

    required this.unread_count,
    this.delete_by = const {},
    this.delete_at = const {},
    this.last_seen_by = const {},

    required this.created_at,
    required this.updated_at,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'chat_id': chat_id,
      'is_enable': is_enable,
      'participants': participants,

      'last_message': last_message,
      'last_message_time': last_message_time != null
          ? Timestamp.fromDate(last_message_time!)
          : null,
      'last_message_sender_id': last_message_sender_id,

      'unread_count': unread_count,
      'delete_by': delete_by,
      'delete_at': delete_at.map((key, value) => MapEntry(key, value?.toIso8601String())),
      'last_seen_by': last_seen_by.map((key, value) => MapEntry(key, value?.toIso8601String())),
          
      'created_at': created_at.toIso8601String(),
      'updated_at': created_at.toIso8601String(),
    };
  }

  /// Convert from Firestore map
  static ChatsModel fromMap(Map<String, dynamic> map) {
    Map<String, DateTime?> lastSeenMap = {};
    if (map['last_seen_by']!= null ) {
      Map<String, dynamic> rawLastSeen = Map<String, dynamic>.from (
        map['last_seen_by'],
      );
      lastSeenMap = rawLastSeen.map(
        (key, value) => MapEntry(
          key, 
          value != null? DateTime.fromMillisecondsSinceEpoch(value):null),
      );
    }

    Map<String, DateTime?> deleteAtMap = {};
    if (map['delete_at']!= null ) {
      Map<String, dynamic> rawDeleteAt = Map<String, dynamic>.from (
        map['delete_at'],
      );
      rawDeleteAt = rawDeleteAt.map(
        (key, value) => MapEntry(
          key, 
          value != null? DateTime.fromMillisecondsSinceEpoch(value):null),
      );
    }

    return ChatsModel(
      chat_id: map['chat_id'] ?? '',
      is_enable: map['is_enable'] ?? true,
      participants: List<String>.from(map['participants'] ?? []),

      last_message: map['last_message'],
      last_message_time: map['last_message_time'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['last_message_time'])
        : null,
      last_message_sender_id: map['last_message_sender_id'],

      unread_count: Map<String, int>.from(map['unread_count'] ?? {}),
      delete_by: Map<String, bool>.from(map['delete_by'] ?? {}),
      delete_at: deleteAtMap,
      last_seen_by: lastSeenMap,

      created_at: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updated_at: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  /// CopyWith
  ChatsModel copyWith({
    String? chat_id,
    bool? is_enable,
    List<String>? participants,
    String? last_message,
    DateTime? last_message_time,
    String? last_message_sender_id,
    Map<String, int>? unread_count,
    Map<String, bool>? delete_by,
    Map<String, DateTime>? delete_at,
    Map<String, DateTime>? last_seen_by,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return ChatsModel(
      chat_id: chat_id ?? this.chat_id,
      is_enable: is_enable ?? this.is_enable,
      participants: participants ?? this.participants,
      last_message: last_message ?? this.last_message,
      last_message_time: last_message_time ?? this.last_message_time,
      last_message_sender_id:
          last_message_sender_id ?? this.last_message_sender_id,
      unread_count: unread_count ?? this.unread_count,
      delete_by: delete_by ?? this.delete_by,
      delete_at: delete_at ?? this.delete_at,
      last_seen_by: last_seen_by ?? this.last_seen_by,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  String getOtherParticipant(String currentUserID) {
    return participants.firstWhere(
      (id) => id != currentUserID,
      orElse: () => '',
    );
  }

  int getUnreadCount(String userID) {
    return unread_count[userID] ?? 0;
  }

  bool isDeleteBy(String userID) {
    return delete_by[userID] ?? false;
  }

  DateTime? getDeleteAt(String userID) {
    return delete_at[userID];
  }

  DateTime? getLastSeenBy(String userID) {
    return last_seen_by[userID];
  }

  bool isMessageSeen(String currentID, String otherID) {
    if (last_message_sender_id == currentID) {
      final otherUserLastSeen = getLastSeenBy(otherID);

      if(otherUserLastSeen != null && last_message_time != null) {
        return otherUserLastSeen.isAtSameMomentAs(last_message_time!);
      }
    }
    return false;
  }
}
