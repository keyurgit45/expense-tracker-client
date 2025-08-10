import 'package:equatable/equatable.dart';

import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/category_analytics.dart';
import '../../domain/entities/spending_trend.dart';

enum AnalyticsPeriod { today, thisMonth, lastMonth, lastThreeMonths, custom }

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsSummary summary;
  final List<CategoryAnalytics> categoryAnalytics;
  final List<SpendingTrend> spendingTrends;
  final AnalyticsPeriod selectedPeriod;
  final DateTime startDate;
  final DateTime endDate;

  const AnalyticsLoaded({
    required this.summary,
    required this.categoryAnalytics,
    required this.spendingTrends,
    required this.selectedPeriod,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        summary,
        categoryAnalytics,
        spendingTrends,
        selectedPeriod,
        startDate,
        endDate,
      ];

  AnalyticsLoaded copyWith({
    AnalyticsSummary? summary,
    List<CategoryAnalytics>? categoryAnalytics,
    List<SpendingTrend>? spendingTrends,
    AnalyticsPeriod? selectedPeriod,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return AnalyticsLoaded(
      summary: summary ?? this.summary,
      categoryAnalytics: categoryAnalytics ?? this.categoryAnalytics,
      spendingTrends: spendingTrends ?? this.spendingTrends,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError({required this.message});

  @override
  List<Object> get props => [message];
}