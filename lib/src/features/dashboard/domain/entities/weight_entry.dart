import 'package:equatable/equatable.dart';

/// Represents a single weight log entry
class WeightEntry extends Equatable {
  final String id;
  final String userId;
  final double weightKg;
  final DateTime date;
  final DateTime createdAt;

  const WeightEntry({
    required this.id,
    required this.userId,
    required this.weightKg,
    required this.date,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, weightKg, date, createdAt];
}
