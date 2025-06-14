import 'package:equatable/equatable.dart';

class AccountSummary extends Equatable {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double incomeChangePercentage;
  final double expenseChangePercentage;
  final String accountNumber;

  const AccountSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.incomeChangePercentage,
    required this.expenseChangePercentage,
    required this.accountNumber,
  });

  @override
  List<Object> get props => [
        totalBalance,
        totalIncome,
        totalExpense,
        incomeChangePercentage,
        expenseChangePercentage,
        accountNumber,
      ];
}