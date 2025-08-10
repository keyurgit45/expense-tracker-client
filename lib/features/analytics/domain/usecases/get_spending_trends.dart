import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/spending_trend.dart';
import '../repositories/analytics_repository.dart';

class GetSpendingTrends implements UseCase<List<SpendingTrend>, GetSpendingTrendsParams> {
  final AnalyticsRepository repository;

  GetSpendingTrends(this.repository);

  @override
  Future<Either<Failure, List<SpendingTrend>>> call(GetSpendingTrendsParams params) async {
    return await repository.getSpendingTrends(
      startDate: params.startDate,
      endDate: params.endDate,
      period: params.period,
    );
  }
}

class GetSpendingTrendsParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final String period;

  const GetSpendingTrendsParams({
    required this.startDate,
    required this.endDate,
    required this.period,
  });

  @override
  List<Object> get props => [startDate, endDate, period];
}