import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/daily_log.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../models/daily_log_model.dart';

/// Dashboard repository implementation
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl({required DashboardRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, DailyLog>> getDailyLog(DateTime date) async {
    try {
      final log = await _remoteDataSource.getDailyLog(date);
      return Right(log);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyLog>>> getDailyLogs({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final logs = await _remoteDataSource.getDailyLogs(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(logs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDailyLog(DailyLog log) async {
    try {
      await _remoteDataSource.updateDailyLog(DailyLogModel.fromEntity(log));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateWaterIntake({
    required DateTime date,
    required double amountMl,
  }) async {
    try {
      await _remoteDataSource.updateWaterIntake(date: date, amountMl: amountMl);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<DailyLog?> watchTodayLog() {
    return _remoteDataSource.watchTodayLog();
  }

  @override
  Future<Either<Failure, List<DailyLog>>> getWeeklySummary() async {
    try {
      final logs = await _remoteDataSource.getWeeklySummary();
      return Right(logs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
