class SubscriptionPlansModel {
  final String plan_id;
  final String plan_name;
  final double price;
  final int duration_days;

  SubscriptionPlansModel({
    required this.plan_id,
    required this.plan_name,
    required this.price,
    required this.duration_days,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'plan_id': plan_id,
      'plan_name': plan_name,
      'price': price,
      'duration_days': duration_days,
    };
  }

  /// Convert from Firestore map
  static SubscriptionPlansModel fromMap(Map<String, dynamic> map) {
    return SubscriptionPlansModel(
      plan_id: map['plan_id'] ?? '',
      plan_name: map['plan_name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      duration_days: map['duration_days'] ?? 0,
    );
  }

  SubscriptionPlansModel copyWith({
    String? plan_id,
    String? plan_name,
    double? price,
    int? duration_days,
  }) {
    return SubscriptionPlansModel(
      plan_id: plan_id ?? this.plan_id,
      plan_name: plan_name ?? this.plan_name,
      price: price ?? this.price,
      duration_days: duration_days ?? this.duration_days,
    );
  }
}