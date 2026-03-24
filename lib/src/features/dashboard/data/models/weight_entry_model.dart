import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/weight_entry.dart';

/// Weight entry model for Firestore serialization
class WeightEntryModel extends WeightEntry {
  const WeightEntryModel({
    required super.id,
    required super.userId,
    required super.weightKg,
    required super.date,
    required super.createdAt,
  });

  /// Create from Firestore document
  factory WeightEntryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeightEntryModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'weightKg': weightKg,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
