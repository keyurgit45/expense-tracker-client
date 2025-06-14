import '../../domain/entities/account_summary.dart';

class AccountSummaryModel {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double incomeChangePercentage;
  final double expenseChangePercentage;
  final String accountNumber;

  const AccountSummaryModel({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.incomeChangePercentage,
    required this.expenseChangePercentage,
    required this.accountNumber,
  });

  factory AccountSummaryModel.fromJson(Map<String, dynamic> json) {
    return AccountSummaryModel(
      totalBalance: (json['total_balance'] as num).toDouble(),
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      incomeChangePercentage: (json['income_change_percentage'] as num).toDouble(),
      expenseChangePercentage: (json['expense_change_percentage'] as num).toDouble(),
      accountNumber: json['account_number'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_balance': totalBalance,
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'income_change_percentage': incomeChangePercentage,
      'expense_change_percentage': expenseChangePercentage,
      'account_number': accountNumber,
    };
  }

  AccountSummary toEntity() {
    return AccountSummary(
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      incomeChangePercentage: incomeChangePercentage,
      expenseChangePercentage: expenseChangePercentage,
      accountNumber: accountNumber,
    );
  }

  factory AccountSummaryModel.fromEntity(AccountSummary entity) {
    return AccountSummaryModel(
      totalBalance: entity.totalBalance,
      totalIncome: entity.totalIncome,
      totalExpense: entity.totalExpense,
      incomeChangePercentage: entity.incomeChangePercentage,
      expenseChangePercentage: entity.expenseChangePercentage,
      accountNumber: entity.accountNumber,
    );
  }
}