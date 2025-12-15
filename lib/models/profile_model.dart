class ProfileModel {
  final String user_id;
  final String bio;
  final List<String> about_me;
  final List<String> communities;
  final String location;
  final List<String> interests;
  final List<String> photos;
  final List<String> values;

  ProfileModel({
    required this.user_id,
    this.about_me = const [],
    this.bio = "",
    this.communities = const [],
    this.location = "",
    this.interests = const [],
    this.photos = const [],
    this.values = const [],
  });

  // Convert từ Firestore Document
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      user_id: map['user_id'] ?? '',
      bio: map['bio'] ?? '',
      about_me: List<String>.from(map['about_me'] ?? []),
      communities: List<String>.from(map['communities'] ?? []),
      location: map['location'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      photos: List<String>.from(map['photos'] ?? []),
      values: List<String>.from(map['values'] ?? []),
    );
  }

  // Convert sang Firestore Document
  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'bio': bio,
      'about_me': about_me,
      'communities': communities,
      'location': location,
      'interests': interests,
      'photos': photos,
      'values': values,
    };
  }

  // Copy with method để update dễ dàng
  ProfileModel copyWith({
    String? user_id,
    String? bio,
    List<String>? about_me,
    List<String>? communities,
    String? location,
    List<String>? interests,
    List<String>? photos,
    List<String>? values,
  }) {
    return ProfileModel(
      user_id: user_id ?? this.user_id,
      bio: bio ?? this.bio,
      about_me: about_me ?? this.about_me,
      communities: communities ?? this.communities,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      photos: photos ?? this.photos,
      values: values ?? this.values,
    );
  }

  // Helper: Kiểm tra profile đã hoàn thiện chưa
  bool get isComplete {
    return bio.isNotEmpty &&
        location.isNotEmpty &&
        photos.isNotEmpty &&
        (about_me.isNotEmpty || interests.isNotEmpty);
  }

  // Helper: Lấy ảnh đại diện (ảnh đầu tiên)
  String get avatarUrl => photos.isNotEmpty ? photos.first : '';
}