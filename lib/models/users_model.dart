import 'package:cloud_firestore/cloud_firestore.dart';
class UsersModel {
  //khai báo các biến 
  // Có ? => có thể null
  // final => không thể thay đổi giá trị
  final String user_id;
  final String first_name;
  final String last_name;
  final String email;
  final String password_hash;
  final String gender;
  final DateTime? date_of_birth;
  final String bio;
  final String location;
  final String profile_picture;
  
  final bool is_online;
  final DateTime created_at;
  final DateTime last_seen;

  //khai báo các thuộc tính của model
  UsersModel({
    required this.user_id,
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.password_hash,
    required this.gender,
    required this.date_of_birth,
    this.bio = "",
    required this.location,
    this.profile_picture = "",

    required this.created_at,
    
    required this.is_online,
    required this.last_seen,

  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      "user_id": user_id,
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
      "created_at": Timestamp.fromDate(created_at),
      "is_online": is_online,
      "last_seen": Timestamp.fromDate(last_seen),
    };
  }

  // Convert from Firestore map
  static UsersModel fromMap(Map<String, dynamic> map) {
    return UsersModel(
      user_id: map["user_id"],
      first_name: map["first_name"],
      last_name: map["last_name"],
      email: map["email"] ?? "",
      password_hash: map["password_hash"] ?? "",
      gender: map["gender"],
      date_of_birth: map['date_of_birth'] != null
        ? (map['date_of_birth'] as Timestamp).toDate()
        : null,
      bio: map["bio"],
      location: map["location"],
      profile_picture: map["profile_picture"],
      
      is_online: map["is_online"] ?? false,
      created_at: (map['created_at'] as Timestamp).toDate(),
      last_seen: (map['last_seen'] as Timestamp).toDate()
  
    );
  }


  //hàm copy with 
  UsersModel copyWith({
    String? user_id,
    String? first_name,
    String? last_name,
    String? email,
    String? password_hash,
    String? gender,
    DateTime? date_of_birth,
    String? bio,
    String? location,
    String? profile_picture,
    bool? is_online,
    DateTime? created_at,
    DateTime? last_seen,
  }) {
    return UsersModel(
      user_id: user_id ?? this.user_id,
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      email: email ?? this.email,
      password_hash: password_hash ?? this.password_hash,
      gender: gender ?? this.gender,
      date_of_birth: date_of_birth ?? this.date_of_birth,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      profile_picture: profile_picture ?? this.profile_picture,
      
      is_online: is_online ?? this.is_online,
      created_at: created_at ?? this.created_at,
      last_seen: last_seen ?? this.last_seen,
    );
  }
}
