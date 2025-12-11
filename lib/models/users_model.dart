import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twinkle/models/blocked_users_model.dart';
import 'package:twinkle/models/photos_model.dart';
import 'package:twinkle/models/user_preferences_model.dart';

class UsersModel {
  final String? first_name;
  final String? last_name;
  final String email;
  final String password_hash;
  final String? gender;
  final DateTime? date_of_birth;
  final String? bio;
  final String? location;
  final String? profile_picture;
  
  final DateTime? created_at;

  final bool is_online;
  final DateTime? last_seen;

  final UserPreferencesModel? user_preferences;
  final PhotosModel? photos;

  final List<BlockedUsersModel>? blocked_users; 


  UsersModel({
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.password_hash,
    required this.gender,
    required this.date_of_birth,
    required this.bio,
    required this.location,
    required this.profile_picture,

    required this.created_at,
    
    required this.is_online,
    required this.last_seen,

    this.user_preferences,
    this.photos,

    this.blocked_users,

  });

  Object? get id => null;

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      "first_name": first_name,
      "last_name": last_name,
      "email": email,
      "password_hash": password_hash,
      "gender": gender,
      "date_of_birth":
          date_of_birth != null ? Timestamp.fromDate(date_of_birth!) : null,
      "bio": bio,
      "location": location,
      "profile_picture": profile_picture,
      "created_at": created_at != null ? Timestamp.fromDate(created_at!) : null,
      
      "is_online": is_online,
      "last_seen":
          last_seen != null ? Timestamp.fromDate(last_seen!) : null,

      "user_preferences": user_preferences?.toMap(),
      "photos": photos?.toMap(),

      'blocked_users': blocked_users?.map((e) => e.toMap()).toList(),
      
    };
  }

  // Convert from Firestore map
  static UsersModel fromMap(Map<String, dynamic> map) {
    return UsersModel(
      first_name: map["first_name"],
      last_name: map["last_name"],
      email: map["email"] ?? "",
      password_hash: map["password_hash"] ?? "",
      gender: map["gender"],
      date_of_birth: map["date_of_birth"] is Timestamp
          ? (map["date_of_birth"] as Timestamp).toDate()
          : null,
      bio: map["bio"],
      location: map["location"],
      profile_picture: map["profile_picture"],
      
      created_at: map["created_at"] is Timestamp
          ? (map["created_at"] as Timestamp).toDate()
          : null,
      
      is_online: map["is_online"] ?? false,
      last_seen: map["last_seen"] is Timestamp
          ? (map["last_seen"] as Timestamp).toDate()
          : null,
      
      user_preferences: map["user_preferences"] != null
          ? UserPreferencesModel.fromMap(map["user_preferences"])
          : null,
      photos: map["photos"] != null ? PhotosModel.fromMap(map["photos"]) : null,

      blocked_users: map["blocked_users"] != null
          ? List<BlockedUsersModel>.from(
              map["blocked_users"].map((x) => BlockedUsersModel.fromMap(x)))
          : null,

    );
  }

  UsersModel copyWith({
    String? first_name,
    String? last_name,
    String? email,
    String? password_hash,
    String? gender,
    DateTime? date_of_birth,
    String? bio,
    String? location,
    String? profile_picture,
    
    DateTime? created_at,
    
    bool? is_online,
    DateTime? last_seen,
    
    UserPreferencesModel? user_preferences,
    PhotosModel? photos,

    List<BlockedUsersModel>? blocked_users,
  }) {
    return UsersModel(
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      email: email ?? this.email,
      password_hash: password_hash ?? this.password_hash,
      gender: gender ?? this.gender,
      date_of_birth: date_of_birth ?? this.date_of_birth,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      profile_picture: profile_picture ?? this.profile_picture,
      
      created_at: created_at ?? this.created_at,
      is_online: is_online ?? this.is_online,
      last_seen: last_seen ?? this.last_seen,
      
      user_preferences: user_preferences ?? this.user_preferences,
      photos: photos ?? this.photos,

      blocked_users: blocked_users ?? this.blocked_users,
    );
  }
}
