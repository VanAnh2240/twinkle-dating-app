class UserPreferencesModel {
  final String preference_id;
  final String interested_in;
  final int age_min;
  final int age_max;
  final int max_distance;

  UserPreferencesModel(
    {
      required this.preference_id,
      required this.interested_in,
      required this.age_min,
      required this.age_max,
      required this.max_distance,
    }
  );

   /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'preference_id' : preference_id,
      'interested_in': interested_in,
      'age_min': age_min,
      'age_max': age_max,
      'max_distance': max_distance,
    };
  }

  /// Convert from Firestore map
  static UserPreferencesModel fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel(
      preference_id: map['preference_id'] ?? '',
      interested_in: map['interested_in'] ?? '',
      age_min: map['age_min'] ?? '18',
      age_max: map['age_max'] ?? '60',
      max_distance: map['max_distance'] ?? '30',
    );
  }

  UserPreferencesModel copyWith ({
    String? preference_id,
    String? interested_in,
    int? age_min,
    int? age_max,
    int? max_distance,
  }) {
    return UserPreferencesModel(
      preference_id: preference_id ?? this.preference_id,
      interested_in: interested_in ?? this.interested_in,
      age_min: age_min ?? this.age_min,
      age_max: age_max ?? this.age_max,
      max_distance: max_distance ?? this.max_distance
    );      
  }
}
