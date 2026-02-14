import 'package:equatable/equatable.dart';

/// Represents a daily nutrition summary
class DailyLog extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final int mealCount;
  final double waterIntakeMl;

  const DailyLog({
    required this.id,
    required this.userId,
    required this.date,
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.totalFiber = 0,
    this.mealCount = 0,
    this.waterIntakeMl = 0,
  });

  /// Calculate calorie goal progress (0.0 - 1.0+)
  double calorieProgress(double goal) => goal > 0 ? totalCalories / goal : 0;

  /// Calculate protein goal progress
  double proteinProgress(double goal) => goal > 0 ? totalProtein / goal : 0;

  /// Calculate carbs goal progress
  double carbsProgress(double goal) => goal > 0 ? totalCarbs / goal : 0;

  /// Calculate fat goal progress
  double fatProgress(double goal) => goal > 0 ? totalFat / goal : 0;

  DailyLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    double? totalFiber,
    int? mealCount,
    double? waterIntakeMl,
  }) {
    return DailyLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber ?? this.totalFiber,
      mealCount: mealCount ?? this.mealCount,
      waterIntakeMl: waterIntakeMl ?? this.waterIntakeMl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    date,
    totalCalories,
    totalProtein,
    totalCarbs,
    totalFat,
    totalFiber,
    mealCount,
    waterIntakeMl,
  ];
}
