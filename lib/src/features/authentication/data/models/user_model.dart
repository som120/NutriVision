import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

/// User model for Firebase serialization/deserialization
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.calorieGoal,
    super.proteinGoal,
    super.carbsGoal,
    super.fatGoal,
    required super.createdAt,
  });

  /// Create from Firebase document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      calorieGoal: (data['calorieGoal'] as num?)?.toDouble() ?? 2000,
      proteinGoal: (data['proteinGoal'] as num?)?.toDouble() ?? 50,
      carbsGoal: (data['carbsGoal'] as num?)?.toDouble() ?? 300,
      fatGoal: (data['fatGoal'] as num?)?.toDouble() ?? 65,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      calorieGoal: entity.calorieGoal,
      proteinGoal: entity.proteinGoal,
      carbsGoal: entity.carbsGoal,
      fatGoal: entity.fatGoal,
      createdAt: entity.createdAt,
    );
  }

  /// Convert to Firebase document map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'calorieGoal': calorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
