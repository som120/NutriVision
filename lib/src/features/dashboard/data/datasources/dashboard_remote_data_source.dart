import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/daily_log_model.dart';

/// Remote data source for dashboard/daily log operations
class DashboardRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DashboardRemoteDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException(message: 'Not authenticated');
    }
    return user.uid;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get daily log for a specific date
  Future<DailyLogModel> getDailyLog(DateTime date) async {
    try {
      final dateKey = _dateKey(date);
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.dailyLogsCollection)
          .doc(dateKey)
          .get();

      if (!doc.exists) {
        return DailyLogModel(
          id: dateKey,
          userId: _userId,
          date: DateTime(date.year, date.month, date.day),
        );
      }

      return DailyLogModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to get daily log: $e');
    }
  }

  /// Get daily logs for a date range
  Future<List<DailyLogModel>> getDailyLogs({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.dailyLogsCollection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date')
          .get();

      return snapshot.docs
          .map((doc) => DailyLogModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get daily logs: $e');
    }
  }

  /// Update daily log
  Future<void> updateDailyLog(DailyLogModel log) async {
    try {
      final dateKey = _dateKey(log.date);
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.dailyLogsCollection)
          .doc(dateKey)
          .set(log.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw ServerException(message: 'Failed to update daily log: $e');
    }
  }

  /// Update water intake
  Future<void> updateWaterIntake({
    required DateTime date,
    required double amountMl,
  }) async {
    try {
      final dateKey = _dateKey(date);
      final ref = _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.dailyLogsCollection)
          .doc(dateKey);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(ref);
        if (doc.exists) {
          final current =
              (doc.data()?['waterIntakeMl'] as num?)?.toDouble() ?? 0;
          transaction.update(ref, {'waterIntakeMl': current + amountMl});
        } else {
          transaction.set(ref, {
            'userId': _userId,
            'date': Timestamp.fromDate(
              DateTime(date.year, date.month, date.day),
            ),
            'totalCalories': 0,
            'totalProtein': 0,
            'totalCarbs': 0,
            'totalFat': 0,
            'totalFiber': 0,
            'mealCount': 0,
            'waterIntakeMl': amountMl,
          });
        }
      });
    } catch (e) {
      throw ServerException(message: 'Failed to update water intake: $e');
    }
  }

  /// Stream today's daily log
  Stream<DailyLogModel?> watchTodayLog() {
    final now = DateTime.now();
    final dateKey = _dateKey(now);

    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(_userId)
        .collection(AppConstants.dailyLogsCollection)
        .doc(dateKey)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return DailyLogModel.fromFirestore(doc);
        });
  }

  /// Get weekly summary (last 7 days)
  Future<List<DailyLogModel>> getWeeklySummary() async {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));

    return getDailyLogs(startDate: startOfWeek, endDate: now);
  }
}
