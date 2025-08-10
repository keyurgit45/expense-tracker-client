import '../../domain/entities/analytics_summary.dart';

class AnalyticsSummaryModel extends AnalyticsSummary {
  const AnalyticsSummaryModel({
    required super.totalIncome,
    required super.totalExpense,
    required super.netCashFlow,
    required super.averageDailySpending,
    required super.transactionCount,
    required super.previousPeriodIncome,
    required super.previousPeriodExpense,
    required super.categoryBreakdown,
    required super.previousCategoryBreakdown,
    required super.startDate,
    required super.endDate,
  });

  factory AnalyticsSummaryModel.fromMap(Map<String, dynamic> map) {
    return AnalyticsSummaryModel(
      totalIncome: (map['totalIncome'] ?? 0).toDouble(),
      totalExpense: (map['totalExpense'] ?? 0).toDouble(),
      netCashFlow: (map['netCashFlow'] ?? 0).toDouble(),
      averageDailySpending: (map['averageDailySpending'] ?? 0).toDouble(),
      transactionCount: map['transactionCount'] ?? 0,
      previousPeriodIncome: (map['previousPeriodIncome'] ?? 0).toDouble(),
      previousPeriodExpense: (map['previousPeriodExpense'] ?? 0).toDouble(),
      categoryBreakdown: Map<String, double>.from(
        (map['categoryBreakdown'] ?? {}).map(
          (key, value) => MapEntry(key, value.toDouble()),
        ),
      ),
      previousCategoryBreakdown: Map<String, double>.from(
        (map['previousCategoryBreakdown'] ?? {}).map(
          (key, value) => MapEntry(key, value.toDouble()),
        ),
      ),
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netCashFlow': netCashFlow,
      'averageDailySpending': averageDailySpending,
      'transactionCount': transactionCount,
      'previousPeriodIncome': previousPeriodIncome,
      'previousPeriodExpense': previousPeriodExpense,
      'categoryBreakdown': categoryBreakdown,
      'previousCategoryBreakdown': previousCategoryBreakdown,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}