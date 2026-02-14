import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Get current authenticated user stream
  Stream<firebase_auth.User?> get authStateChanges;

  /// Get current user
  firebase_auth.User? get currentUser;

  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Get user profile from Firestore
  Future<Either<Failure, UserEntity>> getUserProfile(String uid);

  /// Update user profile in Firestore
  Future<Either<Failure, void>> updateUserProfile(UserEntity user);

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
}
