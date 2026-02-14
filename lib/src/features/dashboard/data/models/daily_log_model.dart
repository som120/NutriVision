import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/daily_log.dart';

/// Daily log model for Firebase serialization/deserialization
class DailyLogModel extends DailyLog {
  const DailyLogModel({
    required super.id,
    required super.userId,
    required super.date,
    super.totalCalories,
    super.totalProtein,
    super.totalCarbs,
    super.totalFat,
    super.totalFiber,
    super.mealCount,
    super.waterIntakeMl,
  });

  /// Create from Firebase document
  factory DailyLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyLogModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalCalories: (data['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProtein: (data['totalProtein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (data['totalCarbs'] as num?)?.toDouble() ?? 0,
      totalFat: (data['totalFat'] as num?)?.toDouble() ?? 0,
      totalFiber: (data['totalFiber'] as num?)?.toDouble() ?? 0,
      mealCount: (data['mealCount'] as num?)?.toInt() ?? 0,
      waterIntakeMl: (data['waterIntakeMl'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Create from DailyLog entity
  factory DailyLogModel.fromEntity(DailyLog entity) {
    return DailyLogModel(
      id: entity.id,
      userId: entity.userId,
      date: entity.date,
      totalCalories: entity.totalCalories,
      totalProtein: entity.totalProtein,
      totalCarbs: entity.totalCarbs,
      totalFat: entity.totalFat,
      totalFiber: entity.totalFiber,
      mealCount: entity.mealCount,
      waterIntakeMl: entity.waterIntakeMl,
    );
  }

  /// Convert to Firebase document map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalFiber': totalFiber,
      'mealCount': mealCount,
      'waterIntakeMl': waterIntakeMl,
    };
  }
}
