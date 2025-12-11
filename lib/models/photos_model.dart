import 'package:cloud_firestore/cloud_firestore.dart';

class PhotosModel { 
  final String? user_id; 
  final String? photo_url;  
  final DateTime uploaded_at;
  
  PhotosModel(
    {
      this.user_id,
      this.photo_url,
      required this.uploaded_at,
    }
  );

   /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'photo_url': photo_url,
      'uploaded_at': 
          uploaded_at != null ? Timestamp.fromDate(uploaded_at!) : null,
    };
  }

    /// Convert from Firestore map
  static PhotosModel fromMap(Map<String, dynamic> map) {
    return PhotosModel(
      user_id: map['user_id'] ?? '',
      photo_url: map['photo_url'] ?? '',
      uploaded_at: DateTime.fromMillisecondsSinceEpoch(map['uploaded_at'] ?? 0),
    );
  }
  
  PhotosModel copyWith ({
    String? user_id,
    String? photo_url,
    DateTime? uploaded_at,
  }) {
    return PhotosModel(
      user_id: user_id ?? this.user_id,
      photo_url: photo_url ?? this.photo_url,
      uploaded_at: uploaded_at ?? this.uploaded_at
    );      
  }
}
