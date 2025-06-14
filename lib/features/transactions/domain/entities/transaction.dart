import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

enum TransactionTag { fee, sale, refund, other }

class Transaction extends Equatable {
  final String id;
  final String description;
  final double amount;
  final TransactionType type;
  final TransactionTag tag;
  final DateTime date;
  final String? categoryId;
  final String? categoryName;
  final String? notes;
  final bool isRecurring;

  const Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.tag,
    required this.date,
    this.categoryId,
    this.categoryName,
    this.notes,
    this.isRecurring = false,
  });

  @override
  List<Object?> get props => [
        id,
        description,
        amount,
        type,
        tag,
        date,
        categoryId,
        categoryName,
        notes,
        isRecurring,
      ];
}