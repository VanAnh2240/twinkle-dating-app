import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsModel {
  final String chat_id;
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

  // ✅ HELPER: Parse DateTime từ mọi format
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
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
      // Try parse as int first
      final intValue = int.tryParse(value);
      if (intValue != null) {
        return DateTime.fromMillisecondsSinceEpoch(intValue);
      }
      // Try parse as ISO string
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('⚠️ Failed to parse datetime string: $value');
        return null;
      }
    }
    
    return null;
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'chat_id': chat_id,
      'participants': participants,
      'last_message': last_message,
      'last_message_time': last_message_time?.millisecondsSinceEpoch,
      'last_message_sender_id': last_message_sender_id,
      'unread_count': unread_count,
      'delete_by': delete_by,
      'delete_at': delete_at.map(
        (key, value) => MapEntry(key, value?.millisecondsSinceEpoch)
      ),
      'last_seen_by': last_seen_by.map(
        (key, value) => MapEntry(key, value?.millisecondsSinceEpoch)
      ),
      'created_at': created_at.millisecondsSinceEpoch,
      'updated_at': updated_at.millisecondsSinceEpoch,
    };
  }

  /// Convert from Firestore map
  static ChatsModel fromMap(Map<String, dynamic> map) {
    Map<String, DateTime?> lastSeenMap = {};
    if (map['last_seen_by'] != null) {
      try {
        final rawLastSeen = Map<String, dynamic>.from(map['last_seen_by']);
        lastSeenMap = rawLastSeen.map(
          (key, value) => MapEntry(key, _parseDateTime(value)),
        );
      } catch (e) {
        print('⚠️ Error parsing last_seen_by: $e');
      }
    }

    Map<String, DateTime?> deleteAtMap = {};
    if (map['delete_at'] != null) {
      try {
        final rawDeleteAt = Map<String, dynamic>.from(map['delete_at']);
        deleteAtMap = rawDeleteAt.map(
          (key, value) => MapEntry(key, _parseDateTime(value)),
        );
      } catch (e) {
        print('⚠️ Error parsing delete_at: $e');
      }
    }

    Map<String, int> unreadCountMap = {};
    if (map['unread_count'] != null) {
      try {
        final rawUnread = Map<String, dynamic>.from(map['unread_count']);
        unreadCountMap = rawUnread.map(
          (key, value) => MapEntry(key, _parseInt(value)),
        );
      } catch (e) {
        print('⚠️ Error parsing unread_count: $e');
      }
    }

    return ChatsModel(
      chat_id: map['chat_id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      last_message: map['last_message'],
      last_message_time: _parseDateTime(map['last_message_time']),
      last_message_sender_id: map['last_message_sender_id'],
      unread_count: unreadCountMap,
      delete_by: Map<String, bool>.from(map['delete_by'] ?? {}),
      delete_at: deleteAtMap,
      last_seen_by: lastSeenMap,
      created_at: _parseDateTime(map['created_at']) ?? DateTime.now(),
      updated_at: _parseDateTime(map['updated_at']) ?? DateTime.now(),
    );
  }

  /// CopyWith
  ChatsModel copyWith({
    String? chat_id,
    List<String>? participants,
    String? last_message,
    DateTime? last_message_time,
    String? last_message_sender_id,
    Map<String, int>? unread_count,
    Map<String, bool>? delete_by,
    Map<String, DateTime?>? delete_at,
    Map<String, DateTime?>? last_seen_by,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return ChatsModel(
      chat_id: chat_id ?? this.chat_id,
      participants: participants ?? this.participants,
      last_message: last_message ?? this.last_message,
      last_message_time: last_message_time ?? this.last_message_time,
      last_message_sender_id: last_message_sender_id ?? this.last_message_sender_id,
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

      if (otherUserLastSeen != null && last_message_time != null) {
        return otherUserLastSeen.isAfter(last_message_time!) ||
               otherUserLastSeen.isAtSameMomentAs(last_message_time!);
      }
    }
    return false;
  }
}