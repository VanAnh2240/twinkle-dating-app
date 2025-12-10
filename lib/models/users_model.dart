class UsersModel {
  final int? user_id; 
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
  final DateTime last_seen;
  

  UsersModel(
    {
      required this.user_id,
      required this.first_name,
      required this.last_name,
      required this.email,
      required this.password_hash,
      this.gender,
      this.date_of_birth,
      this.bio,
      this.location,
      this.profile_picture,
      required this.created_at,
      this.is_online = false,
      required this.last_seen,
    }
  );

  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'password_hash': password_hash,
      'gender': gender,
      'date_of_birth': date_of_birth,
      'bio': bio,
      'location': location,
      'profile_picture': profile_picture,
      'created_at': created_at,
      'is_online': is_online,
      'last_seen': last_seen,
    };
  }

  static UsersModel fromMap(Map<String, dynamic> map) {
    return UsersModel(
      user_id: map['user_id'] ?? '',
      first_name: map['first_name'] ?? '',
      last_name: map['last_name'] ?? '',
      email: map['email'] ?? '',
      password_hash: map['password_hash'] ?? '',
      gender: map['gender'] ?? '',
      date_of_birth: map['date_of_birth'] ?? '',
      bio: map['bio'] ?? '',
      location: map['location'] ?? '',
      profile_picture: map['profile_picture'] ?? '',
      created_at: DateTime.fromMillisecondsSinceEpoch(map['created_at'] ?? 0),
      is_online: map['is_online'] ?? false,
      last_seen: DateTime.fromMillisecondsSinceEpoch(map['last_seen'] ?? 0),
    );
  }
  
  UsersModel copyWith ({
    int? user_id,
    String? first_name,
    String? last_name,
    required String email,
    required String password_hash,
    String? gender,
    DateTime? date_of_birth, 
    String? bio,
    String? location,
    String? profile_picture,
    DateTime? created_at,
    bool? is_online,
    DateTime? last_seen,
  }) {
    return UsersModel(
      user_id: user_id ?? this.user_id,
      first_name: first_name ?? this.first_name,
      last_name: last_name ?? this.last_name,
      email: email,
      password_hash: password_hash,
      gender: gender ?? this.gender,
      date_of_birth: date_of_birth ?? this.date_of_birth,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      profile_picture: profile_picture ?? this.profile_picture,
      created_at: created_at ?? this.created_at,
      is_online: is_online ?? this.is_online,
      last_seen: last_seen ?? this.last_seen
    );      
  }
}
