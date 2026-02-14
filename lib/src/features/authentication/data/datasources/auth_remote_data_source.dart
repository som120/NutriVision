import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Remote data source for authentication operations
class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw const AuthException(message: 'Sign in failed');
      }
      return await getUserProfile(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapAuthError(e.code));
    }
  }

  /// Sign up with email
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw const AuthException(message: 'Sign up failed');
      }

      await credential.user!.updateDisplayName(displayName);

      final user = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toFirestore());

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapAuthError(e.code));
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      final credential = await _auth.signInWithProvider(googleProvider);

      if (credential.user == null) {
        throw const AuthException(message: 'Google sign in failed');
      }

      // Check if user exists in Firestore
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        final user = UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? '',
          displayName: credential.user!.displayName,
          photoUrl: credential.user!.photoURL,
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(user.toFirestore());
        return user;
      }

      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapAuthError(e.code));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get user profile
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        // Create profile if not exists
        final user = UserModel(
          uid: uid,
          email: _auth.currentUser?.email ?? '',
          displayName: _auth.currentUser?.displayName,
          photoUrl: _auth.currentUser?.photoURL,
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .set(user.toFirestore());
        return user;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(user.toFirestore());
    } catch (e) {
      throw ServerException(message: 'Failed to update user profile: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapAuthError(e.code));
    }
  }

  /// Map Firebase auth error codes to user-friendly messages
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
