import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/weight_entry_model.dart';

/// Remote data source for weight tracking operations
class WeightRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WeightRemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Not authenticated');
    }
    return user.uid;
  }

  CollectionReference get _weightCollection => _firestore
      .collection(AppConstants.usersCollection)
      .doc(_userId)
      .collection(AppConstants.weightEntriesCollection);

  /// Add a new weight entry
  Future<void> addWeightEntry(WeightEntryModel entry) async {
    try {
      await _weightCollection.add(entry.toFirestore());
    } catch (e) {
      throw ServerException(message: 'Failed to add weight entry: $e');
    }
  }

  /// Get weight entries for the last N days
  Future<List<WeightEntryModel>> getWeightEntries({int days = 90}) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _weightCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => WeightEntryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get weight entries: $e');
    }
  }

  /// Stream weight entries for the last N days (for real-time updates)
  Stream<List<WeightEntryModel>> watchWeightEntries({int days = 90}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _weightCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WeightEntryModel.fromFirestore(doc))
            .toList());
  }

  /// Delete a weight entry
  Future<void> deleteWeightEntry(String entryId) async {
    try {
      await _weightCollection.doc(entryId).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete weight entry: $e');
    }
  }
}
