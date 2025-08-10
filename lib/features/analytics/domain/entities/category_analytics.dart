import 'package:equatable/equatable.dart';

class CategoryAnalytics extends Equatable {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;
  final int transactionCount;
  final double previousAmount;
  final double changePercentage;

  const CategoryAnalytics({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    required this.previousAmount,
    required this.changePercentage,
  });

  @override
  List<Object> get props => [
        categoryId,
        categoryName,
        amount,
        percentage,
        transactionCount,
        previousAmount,
        changePercentage,
      ];
}