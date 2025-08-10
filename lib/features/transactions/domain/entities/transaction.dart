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

  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    TransactionType? type,
    TransactionTag? tag,
    DateTime? date,
    String? categoryId,
    String? categoryName,
    String? notes,
    bool? isRecurring,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      tag: tag ?? this.tag,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}