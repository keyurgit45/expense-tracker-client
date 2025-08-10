import '../../domain/entities/spending_trend.dart';

class SpendingTrendModel extends SpendingTrend {
  const SpendingTrendModel({
    required super.date,
    required super.amount,
    required super.period,
  });

  factory SpendingTrendModel.fromMap(Map<String, dynamic> map) {
    return SpendingTrendModel(
      date: DateTime.parse(map['date']),
      amount: (map['amount'] ?? 0).toDouble(),
      period: map['period'] ?? 'day',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'period': period,
    };
  }
}