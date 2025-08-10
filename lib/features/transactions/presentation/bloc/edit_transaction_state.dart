part of 'edit_transaction_cubit.dart';

abstract class EditTransactionState extends Equatable {
  const EditTransactionState();

  @override
  List<Object?> get props => [];
}

class EditTransactionInitial extends EditTransactionState {}

class EditTransactionLoaded extends EditTransactionState {
  final Transaction transaction;
  final double amount;
  final String description;
  final String? categoryId;
  final String? categoryName;
  final DateTime date;
  final TransactionType type;
  final String notes;
  final bool isRecurring;
  final TransactionTag tag;

  const EditTransactionLoaded({
    required this.transaction,
    required this.amount,
    required this.description,
    this.categoryId,
    this.categoryName,
    required this.date,
    required this.type,
    required this.notes,
    required this.isRecurring,
    required this.tag,
  });

  @override
  List<Object?> get props => [
        transaction,
        amount,
        description,
        categoryId,
        categoryName,
        date,
        type,
        notes,
        isRecurring,
        tag,
      ];

  EditTransactionLoaded copyWith({
    Transaction? transaction,
    double? amount,
    String? description,
    String? categoryId,
    String? categoryName,
    DateTime? date,
    TransactionType? type,
    String? notes,
    bool? isRecurring,
    TransactionTag? tag,
  }) {
    return EditTransactionLoaded(
      transaction: transaction ?? this.transaction,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      date: date ?? this.date,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      tag: tag ?? this.tag,
    );
  }
}

class EditTransactionSaving extends EditTransactionState {}

class EditTransactionSuccess extends EditTransactionState {
  final Transaction transaction;

  const EditTransactionSuccess({required this.transaction});

  @override
  List<Object> get props => [transaction];
}

class EditTransactionError extends EditTransactionState {
  final String message;

  const EditTransactionError({required this.message});

  @override
  List<Object> get props => [message];
}