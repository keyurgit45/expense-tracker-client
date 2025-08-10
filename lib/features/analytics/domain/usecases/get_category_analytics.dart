import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category_analytics.dart';
import '../repositories/analytics_repository.dart';

class GetCategoryAnalytics implements UseCase<List<CategoryAnalytics>, GetCategoryAnalyticsParams> {
  final AnalyticsRepository repository;

  GetCategoryAnalytics(this.repository);

  @override
  Future<Either<Failure, List<CategoryAnalytics>>> call(GetCategoryAnalyticsParams params) async {
    return await repository.getCategoryAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetCategoryAnalyticsParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const GetCategoryAnalyticsParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}