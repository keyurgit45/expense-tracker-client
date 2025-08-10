import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/category_analytics.dart';
import '../../domain/entities/spending_trend.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AnalyticsSummary>> getAnalyticsSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await remoteDataSource.getAnalyticsSummary(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure(message: 'Failed to get analytics summary'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryAnalytics>>> getCategoryAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await remoteDataSource.getCategoryAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure(message: 'Failed to get category analytics'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SpendingTrend>>> getSpendingTrends({
    required DateTime startDate,
    required DateTime endDate,
    required String period,
  }) async {
    try {
      final result = await remoteDataSource.getSpendingTrends(
        startDate: startDate,
        endDate: endDate,
        period: period,
      );
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure(message: 'Failed to get spending trends'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}