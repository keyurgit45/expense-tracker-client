import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/usecases/update_transaction.dart';

part 'edit_transaction_state.dart';

class EditTransactionCubit extends Cubit<EditTransactionState> {
  final UpdateTransaction updateTransaction;

  EditTransactionCubit({
    required this.updateTransaction,
  }) : super(EditTransactionInitial());

  void initializeWithTransaction(Transaction transaction) {
    // Store the signed amount based on the transaction type
    final signedAmount = transaction.type == TransactionType.expense
        ? -transaction.amount
        : transaction.amount;

    emit(EditTransactionLoaded(
      transaction: transaction,
      amount: signedAmount,
      description: transaction.description,
      categoryId: transaction.categoryId,
      categoryName: transaction.categoryName,
      date: transaction.date,
      type: transaction.type,
      notes: transaction.notes ?? '',
      isRecurring: transaction.isRecurring,
      tag: transaction.tag,
    ));
  }

  void updateAmount(double amount) {
    if (state is EditTransactionLoaded) {
      final currentState = state as EditTransactionLoaded;
      emit(currentState.copyWith(amount: amount));
    }
  }

  void updateDescription(String description) {
    if (state is EditTransactionLoaded) {
      final currentState = state as EditTransactionLoaded;
      emit(currentState.copyWith(description: description));
    }
  }

  void updateCategory(String? categoryId, String? categoryName) {
    if (state is EditTransactionLoaded) {
      final currentState = state as EditTransactionLoaded;

      emit(currentState.copyWith(
        categoryId: categoryId,
        categoryName: categoryName,
      ));
    }
  }

  void updateDate(DateTime date) {
    if (state is EditTransactionLoaded) {
      final currentState = state as EditTransactionLoaded;
      emit(currentState.copyWith(date: date));
    }
  }

  void updateType(TransactionType type) {
    if (state is EditTransactionLoaded) {
      final currentState = state as EditTransactionLoaded;

      // When changing type, we need to update the amount sign accordingly
      double newAmount;
      if (type == TransactionType.expense) {
        // If changing to expense, make amount negative
        newAmount = -currentState.amount.abs();
      } else {
        // If changing to income, make amount positive
        newAmount = currentState.amount.abs();
      }

      emit(currentState.copyWith(
        type: type,
        amount: newAmount,
      ));
    }
  }

  void updateNotes(String notes) {
    if (state is EditTransactionLoaded) {
      final currentState = state as EditTransactionLoaded;
      emit(currentState.copyWith(notes: notes));
    }
  }

  void updateIsRecurring(bool isRecurring) {
    if (state is EditTransactionLoaded) {
      final currentState = state as EditTransactionLoaded;
      emit(currentState.copyWith(isRecurring: isRecurring));
    }
  }

  void updateTag(TransactionTag tag) {
    if (state is EditTransactionLoaded) {
      final currentState = state as EditTransactionLoaded;
      emit(currentState.copyWith(tag: tag));
    }
  }

  Future<void> saveTransaction() async {
    if (state is EditTransactionLoaded) {
      final currentState = state as EditTransactionLoaded;
      emit(EditTransactionSaving());

      try {
        // Create updated transaction with correct sign for amount
        final updatedAmount = currentState.amount;

        final updatedTransaction = currentState.transaction.copyWith(
          amount: updatedAmount,
          description: currentState.description,
          categoryId: currentState.categoryId,
          categoryName: currentState.categoryName,
          date: currentState.date,
          type: currentState.type,
          notes: currentState.notes.isEmpty ? null : currentState.notes,
          isRecurring: currentState.isRecurring,
          tag: currentState.tag,
        );

        final result = await updateTransaction(
          UpdateTransactionParams(transaction: updatedTransaction),
        );

        result.fold(
          (failure) => emit(EditTransactionError(message: failure.message)),
          (transaction) =>
              emit(EditTransactionSuccess(transaction: transaction)),
        );
      } catch (e) {
        emit(EditTransactionError(message: 'Failed to update transaction: $e'));
      }
    }
  }
}
