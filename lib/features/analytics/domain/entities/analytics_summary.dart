import 'package:equatable/equatable.dart';

class AnalyticsSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double netCashFlow;
  final double averageDailySpending;
  final int transactionCount;
  final double previousPeriodIncome;
  final double previousPeriodExpense;
  final Map<String, double> categoryBreakdown;
  final Map<String, double> previousCategoryBreakdown;
  final DateTime startDate;
  final DateTime endDate;

  const AnalyticsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashFlow,
    required this.averageDailySpending,
    required this.transactionCount,
    required this.previousPeriodIncome,
    required this.previousPeriodExpense,
    required this.categoryBreakdown,
    required this.previousCategoryBreakdown,
    required this.startDate,
    required this.endDate,
  });

  double get incomeChangePercentage {
    if (previousPeriodIncome == 0) return 0;
    return ((totalIncome - previousPeriodIncome) / previousPeriodIncome) * 100;
  }

  double get expenseChangePercentage {
    if (previousPeriodExpense == 0) return 0;
    return ((totalExpense - previousPeriodExpense) / previousPeriodExpense) * 100;
  }

  @override
  List<Object> get props => [
        totalIncome,
        totalExpense,
        netCashFlow,
        averageDailySpending,
        transactionCount,
        previousPeriodIncome,
        previousPeriodExpense,
        categoryBreakdown,
        previousCategoryBreakdown,
        startDate,
        endDate,
      ];
}