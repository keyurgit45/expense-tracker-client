import '../../domain/entities/category_analytics.dart';

class CategoryAnalyticsModel extends CategoryAnalytics {
  const CategoryAnalyticsModel({
    required super.categoryId,
    required super.categoryName,
    required super.amount,
    required super.percentage,
    required super.transactionCount,
    required super.previousAmount,
    required super.changePercentage,
  });

  factory CategoryAnalyticsModel.fromMap(Map<String, dynamic> map) {
    return CategoryAnalyticsModel(
      categoryId: map['category_id'] ?? '',
      categoryName: map['categoryName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      percentage: (map['percentage'] ?? 0).toDouble(),
      transactionCount: map['transactionCount'] ?? 0,
      previousAmount: (map['previousAmount'] ?? 0).toDouble(),
      changePercentage: (map['changePercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category_id': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'percentage': percentage,
      'transactionCount': transactionCount,
      'previousAmount': previousAmount,
      'changePercentage': changePercentage,
    };
  }
}