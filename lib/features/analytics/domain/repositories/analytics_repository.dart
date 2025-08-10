import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/analytics_summary.dart';
import '../entities/category_analytics.dart';
import '../entities/spending_trend.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, AnalyticsSummary>> getAnalyticsSummary({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, List<CategoryAnalytics>>> getCategoryAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, List<SpendingTrend>>> getSpendingTrends({
    required DateTime startDate,
    required DateTime endDate,
    required String period,
  });
}