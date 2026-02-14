import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/daily_log.dart';

/// Dashboard repository interface
abstract class DashboardRepository {
  /// Get daily log for a specific date
  Future<Either<Failure, DailyLog>> getDailyLog(DateTime date);

  /// Get daily logs for a date range (for charts)
  Future<Either<Failure, List<DailyLog>>> getDailyLogs({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Update daily log (called when meal is added/removed)
  Future<Either<Failure, void>> updateDailyLog(DailyLog log);

  /// Update water intake
  Future<Either<Failure, void>> updateWaterIntake({
    required DateTime date,
    required double amountMl,
  });

  /// Stream of today's daily log
  Stream<DailyLog?> watchTodayLog();

  /// Get weekly summary
  Future<Either<Failure, List<DailyLog>>> getWeeklySummary();
}
