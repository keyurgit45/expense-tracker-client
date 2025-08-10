import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_analytics_summary.dart';
import '../../domain/usecases/get_category_analytics.dart';
import '../../domain/usecases/get_spending_trends.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final GetAnalyticsSummary getAnalyticsSummary;
  final GetCategoryAnalytics getCategoryAnalytics;
  final GetSpendingTrends getSpendingTrends;

  AnalyticsCubit({
    required this.getAnalyticsSummary,
    required this.getCategoryAnalytics,
    required this.getSpendingTrends,
  }) : super(AnalyticsInitial());

  Future<void> loadAnalytics({AnalyticsPeriod? period}) async {
    emit(AnalyticsLoading());

    final selectedPeriod = period ?? AnalyticsPeriod.thisMonth;
    final dateRange = _getDateRange(selectedPeriod);

    final summaryResult = await getAnalyticsSummary(
      GetAnalyticsSummaryParams(
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
    );

    final categoryResult = await getCategoryAnalytics(
      GetCategoryAnalyticsParams(
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
    );

    final trendsResult = await getSpendingTrends(
      GetSpendingTrendsParams(
        startDate: dateRange.start,
        endDate: dateRange.end,
        period: _getTrendPeriod(selectedPeriod),
      ),
    );

    if (summaryResult.isRight() && categoryResult.isRight() && trendsResult.isRight()) {
      emit(AnalyticsLoaded(
        summary: summaryResult.getOrElse(() => throw Exception()),
        categoryAnalytics: categoryResult.getOrElse(() => []),
        spendingTrends: trendsResult.getOrElse(() => []),
        selectedPeriod: selectedPeriod,
        startDate: dateRange.start,
        endDate: dateRange.end,
      ));
    } else {
      // Get specific error messages
      String errorMessage = 'Failed to load analytics:\n';
      
      summaryResult.fold(
        (failure) => errorMessage += 'Summary: ${failure.message}\n',
        (_) => null,
      );
      
      categoryResult.fold(
        (failure) => errorMessage += 'Categories: ${failure.message}\n',
        (_) => null,
      );
      
      trendsResult.fold(
        (failure) => errorMessage += 'Trends: ${failure.message}\n',
        (_) => null,
      );
      
      emit(AnalyticsError(message: errorMessage));
    }
  }

  Future<void> changePeriod(AnalyticsPeriod period) async {
    await loadAnalytics(period: period);
  }

  Future<void> setCustomDateRange(DateTime start, DateTime end) async {
    emit(AnalyticsLoading());

    final summaryResult = await getAnalyticsSummary(
      GetAnalyticsSummaryParams(startDate: start, endDate: end),
    );

    final categoryResult = await getCategoryAnalytics(
      GetCategoryAnalyticsParams(startDate: start, endDate: end),
    );

    final trendsResult = await getSpendingTrends(
      GetSpendingTrendsParams(
        startDate: start,
        endDate: end,
        period: _getCustomTrendPeriod(start, end),
      ),
    );

    if (summaryResult.isRight() && categoryResult.isRight() && trendsResult.isRight()) {
      emit(AnalyticsLoaded(
        summary: summaryResult.getOrElse(() => throw Exception()),
        categoryAnalytics: categoryResult.getOrElse(() => []),
        spendingTrends: trendsResult.getOrElse(() => []),
        selectedPeriod: AnalyticsPeriod.custom,
        startDate: start,
        endDate: end,
      ));
    } else {
      emit(const AnalyticsError(message: 'Failed to load analytics'));
    }
  }

  ({DateTime start, DateTime end}) _getDateRange(AnalyticsPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case AnalyticsPeriod.today:
        return (start: today, end: today);
      case AnalyticsPeriod.thisMonth:
        final startOfMonth = DateTime(today.year, today.month, 1);
        return (start: startOfMonth, end: today);
      case AnalyticsPeriod.lastMonth:
        // Handle year boundary correctly
        final lastMonthDate = DateTime(today.year, today.month - 1);
        final lastMonth = DateTime(lastMonthDate.year, lastMonthDate.month, 1);
        final endOfLastMonth = DateTime(today.year, today.month, 0);
        return (start: lastMonth, end: endOfLastMonth);
      case AnalyticsPeriod.lastThreeMonths:
        // Handle year boundary correctly
        final threeMonthsAgo = DateTime(today.year, today.month - 3, today.day);
        return (start: threeMonthsAgo, end: today);
      case AnalyticsPeriod.custom:
        // Default to current month for custom
        final startOfMonth = DateTime(today.year, today.month, 1);
        return (start: startOfMonth, end: today);
    }
  }

  String _getTrendPeriod(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.today:
        return 'day';
      case AnalyticsPeriod.thisMonth:
      case AnalyticsPeriod.lastMonth:
        return 'week';
      case AnalyticsPeriod.lastThreeMonths:
      case AnalyticsPeriod.custom:
        return 'month';
    }
  }

  String _getCustomTrendPeriod(DateTime start, DateTime end) {
    final daysDifference = end.difference(start).inDays;
    if (daysDifference <= 7) {
      return 'day';
    } else if (daysDifference <= 90) {
      return 'week';
    } else {
      return 'month';
    }
  }
}