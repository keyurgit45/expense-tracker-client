import 'package:equatable/equatable.dart';

class SpendingTrend extends Equatable {
  final DateTime date;
  final double amount;
  final String period; // 'day', 'week', 'month'

  const SpendingTrend({
    required this.date,
    required this.amount,
    required this.period,
  });

  @override
  List<Object> get props => [date, amount, period];
}