import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/analytics_summary_model.dart';
import '../models/category_analytics_model.dart';
import '../models/spending_trend_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<AnalyticsSummaryModel> getAnalyticsSummary({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<CategoryAnalyticsModel>> getCategoryAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<SpendingTrendModel>> getSpendingTrends({
    required DateTime startDate,
    required DateTime endDate,
    required String period,
  });
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final SupabaseClient supabaseClient;

  AnalyticsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<AnalyticsSummaryModel> getAnalyticsSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {

      // Calculate previous period dates
      final periodDuration = endDate.difference(startDate);
      final previousStartDate = startDate.subtract(periodDuration);
      final previousEndDate = startDate.subtract(const Duration(days: 1));

      // Get current period transactions
      // Debug: Date range for current period

      try {
        // First, test if we can query transactions at all
        final testQuery =
            await supabaseClient.from('transactions').select().limit(1);
        if (testQuery.isNotEmpty) {
          // Debug: Check sample record structure

          // Check for alternative date field names
          if (testQuery.first['created_at'] != null) {
            // Debug: Found created_at field
          }
          if (testQuery.first['transaction_date'] != null) {
            // Debug: Found transaction_date field
          }
        }
      } catch (e) {
        // Debug: Test query failed
      }

      final currentTransactions = await supabaseClient
          .from('transactions')
          .select('*, categories(*)')
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());


      // Get previous period transactions
      final previousTransactions = await supabaseClient
          .from('transactions')
          .select('*, categories(*)')
          .gte('date', previousStartDate.toIso8601String())
          .lte('date', previousEndDate.toIso8601String());

      // Calculate metrics
      double totalIncome = 0;
      double totalExpense = 0;
      Map<String, double> categoryBreakdown = {};

      for (final transaction in currentTransactions) {
        final amount = (transaction['amount'] ?? 0).toDouble();
        if (amount > 0) {
          totalIncome += amount;
        } else {
          totalExpense += amount.abs();
        }

        if (amount < 0) {
          // Only add expenses to category breakdown
          final categoryName = transaction['categories'] != null
              ? transaction['categories']['name'] ?? 'Uncategorized'
              : 'Uncategorized';
          categoryBreakdown[categoryName] =
              (categoryBreakdown[categoryName] ?? 0) + amount.abs();
        }
      }

      double previousIncome = 0;
      double previousExpense = 0;
      Map<String, double> previousCategoryBreakdown = {};

      for (final transaction in previousTransactions) {
        final amount = (transaction['amount'] ?? 0).toDouble();
        if (amount > 0) {
          previousIncome += amount;
        } else {
          previousExpense += amount.abs();
        }

        if (amount < 0) {
          // Only add expenses to category breakdown
          final categoryName = transaction['categories'] != null
              ? transaction['categories']['name'] ?? 'Uncategorized'
              : 'Uncategorized';
          previousCategoryBreakdown[categoryName] =
              (previousCategoryBreakdown[categoryName] ?? 0) + amount.abs();
        }
      }

      final daysDifference = endDate.difference(startDate).inDays + 1;
      final averageDailySpending =
          daysDifference > 0 ? totalExpense / daysDifference : 0;

      return AnalyticsSummaryModel(
        totalIncome: totalIncome.toDouble(),
        totalExpense: totalExpense.toDouble(),
        netCashFlow: (totalIncome - totalExpense).toDouble(),
        averageDailySpending: averageDailySpending.toDouble(),
        transactionCount: currentTransactions.length,
        previousPeriodIncome: previousIncome.toDouble(),
        previousPeriodExpense: previousExpense.toDouble(),
        categoryBreakdown: categoryBreakdown,
        previousCategoryBreakdown: previousCategoryBreakdown,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      // Check if it's a Supabase error
      if (e.toString().contains('PostgrestException')) {
        // Debug: PostgrestException encountered
      }

      throw Exception('Failed to get analytics summary: $e');
    }
  }

  @override
  Future<List<CategoryAnalyticsModel>> getCategoryAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Calculate previous period dates
      final periodDuration = endDate.difference(startDate);
      final previousStartDate = startDate.subtract(periodDuration);
      final previousEndDate = startDate.subtract(const Duration(days: 1));

      // Get current period transactions grouped by category
      final currentData = await supabaseClient
          .from('transactions')
          .select('amount, categories(category_id, name)')
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .lt('amount', 0); // Only expenses

      // Get previous period data
      final previousData = await supabaseClient
          .from('transactions')
          .select('amount, categories(category_id, name)')
          .gte('date', previousStartDate.toIso8601String())
          .lte('date', previousEndDate.toIso8601String())
          .lt('amount', 0); // Only expenses

      // Process current period data
      Map<String, Map<String, dynamic>> categoryData = {};
      double totalAmount = 0;

      for (final transaction in currentData) {
        final amount = (transaction['amount'] ?? 0).toDouble().abs();
        final category = transaction['categories'];
        final categoryId =
            category != null ? category['category_id'] : 'uncategorized';
        final categoryName =
            category != null ? category['name'] : 'Uncategorized';

        if (!categoryData.containsKey(categoryId)) {
          categoryData[categoryId] = {
            'id': categoryId,
            'name': categoryName,
            'amount': 0.0,
            'count': 0,
            'previousAmount': 0.0,
          };
        }

        categoryData[categoryId]!['amount'] += amount;
        categoryData[categoryId]!['count'] += 1;
        totalAmount += amount;
      }

      // Process previous period data
      for (final transaction in previousData) {
        final amount = (transaction['amount'] ?? 0).toDouble().abs();
        final category = transaction['categories'];
        final categoryId =
            category != null ? category['category_id'] : 'uncategorized';

        if (categoryData.containsKey(categoryId)) {
          categoryData[categoryId]!['previousAmount'] += amount;
        }
      }

      // Convert to CategoryAnalyticsModel list
      List<CategoryAnalyticsModel> result = [];

      categoryData.forEach((categoryId, data) {
        final amount = data['amount'] as double;
        final previousAmount = data['previousAmount'] as double;
        final percentage =
            totalAmount > 0 ? (amount / totalAmount) * 100.0 : 0.0;
        final changePercentage = previousAmount > 0
            ? ((amount - previousAmount) / previousAmount) * 100.0
            : 0.0;

        result.add(CategoryAnalyticsModel(
          categoryId: categoryId,
          categoryName: data['name'],
          amount: amount,
          percentage: percentage,
          transactionCount: data['count'],
          previousAmount: previousAmount,
          changePercentage: changePercentage,
        ));
      });

      // Sort by amount descending
      result.sort((a, b) => b.amount.compareTo(a.amount));

      return result;
    } catch (e) {
      throw Exception('Failed to get category analytics: $e');
    }
  }

  @override
  Future<List<SpendingTrendModel>> getSpendingTrends({
    required DateTime startDate,
    required DateTime endDate,
    required String period,
  }) async {
    try {
      final transactions = await supabaseClient
          .from('transactions')
          .select('date, amount')
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .lt('amount', 0) // Only expenses
          .order('date');

      Map<String, double> groupedData = {};

      for (final transaction in transactions) {
        final date = DateTime.parse(transaction['date']);
        final amount = (transaction['amount'] ?? 0).toDouble().abs();

        String key;
        if (period == 'day') {
          key =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        } else if (period == 'week') {
          // Get start of week (Monday)
          final weekDay = date.weekday;
          final startOfWeek = date.subtract(Duration(days: weekDay - 1));
          key =
              '${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}';
        } else {
          // month
          key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        }

        groupedData[key] = (groupedData[key] ?? 0) + amount;
      }

      // Convert to SpendingTrendModel list
      List<SpendingTrendModel> result = [];

      groupedData.forEach((key, amount) {
        DateTime trendDate;
        if (period == 'month') {
          final parts = key.split('-');
          trendDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
        } else {
          trendDate = DateTime.parse(key);
        }

        result.add(SpendingTrendModel(
          date: trendDate,
          amount: amount,
          period: period,
        ));
      });

      // Sort by date
      result.sort((a, b) => a.date.compareTo(b.date));

      return result;
    } catch (e) {
      throw Exception('Failed to get spending trends: $e');
    }
  }
}
