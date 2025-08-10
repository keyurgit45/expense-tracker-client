import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/analytics_summary.dart';
import '../repositories/analytics_repository.dart';

class GetAnalyticsSummary implements UseCase<AnalyticsSummary, GetAnalyticsSummaryParams> {
  final AnalyticsRepository repository;

  GetAnalyticsSummary(this.repository);

  @override
  Future<Either<Failure, AnalyticsSummary>> call(GetAnalyticsSummaryParams params) async {
    return await repository.getAnalyticsSummary(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetAnalyticsSummaryParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const GetAnalyticsSummaryParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}