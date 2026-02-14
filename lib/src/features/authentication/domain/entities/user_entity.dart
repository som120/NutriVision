import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final double calorieGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.calorieGoal = 2000,
    this.proteinGoal = 50,
    this.carbsGoal = 300,
    this.fatGoal = 65,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    double? calorieGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoUrl,
    calorieGoal,
    proteinGoal,
    carbsGoal,
    fatGoal,
    createdAt,
  ];
}
