import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../categories/domain/entities/category.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import 'transactions_list_state.dart';

class TransactionsListCubit extends Cubit<TransactionsListState> {
  final TransactionRepository _transactionRepository;

  TransactionsListCubit(this._transactionRepository) : super(TransactionsListInitial());

  Future<void> loadTransactions() async {
    emit(TransactionsListLoading());

    final transactionsResult = await _transactionRepository.getTransactions();

    if (transactionsResult.isLeft()) {
      emit(TransactionsListError(
        message: transactionsResult.fold(
          (failure) => failure.message,
          (_) => '',
        ),
      ));
      return;
    }

    final transactions = transactionsResult.getOrElse(() => []);
    
    // Mock categories for now
    final categories = [
      const Category(id: '1', name: 'Shopping'),
      const Category(id: '2', name: 'Food'),
      const Category(id: '3', name: 'Transport'),
      const Category(id: '4', name: 'Entertainment'),
      const Category(id: '5', name: 'Health'),
      const Category(id: '6', name: 'Others'),
    ];

    emit(TransactionsListLoaded(
      transactions: transactions,
      filteredTransactions: transactions,
      categories: categories,
    ));
  }

  void filterByType(TransactionTypeFilter filter) {
    if (state is TransactionsListLoaded) {
      final currentState = state as TransactionsListLoaded;
      final filtered = _applyFilters(
        currentState.transactions,
        filter,
        currentState.categoryFilter,
        currentState.recurringFilter,
      );
      
      emit(currentState.copyWith(
        typeFilter: filter,
        filteredTransactions: filtered,
      ));
    }
  }

  void filterByCategory(String? categoryId) {
    if (state is TransactionsListLoaded) {
      final currentState = state as TransactionsListLoaded;
      final filtered = _applyFilters(
        currentState.transactions,
        currentState.typeFilter,
        categoryId,
        currentState.recurringFilter,
      );
      
      emit(currentState.copyWith(
        categoryFilter: () => categoryId,
        filteredTransactions: filtered,
      ));
    }
  }

  void filterByRecurring(RecurringFilter filter) {
    if (state is TransactionsListLoaded) {
      final currentState = state as TransactionsListLoaded;
      final filtered = _applyFilters(
        currentState.transactions,
        currentState.typeFilter,
        currentState.categoryFilter,
        filter,
      );
      
      emit(currentState.copyWith(
        recurringFilter: filter,
        filteredTransactions: filtered,
      ));
    }
  }

  List<Transaction> _applyFilters(
    List<Transaction> transactions,
    TransactionTypeFilter typeFilter,
    String? categoryFilter,
    RecurringFilter recurringFilter,
  ) {
    var filtered = transactions;

    // Apply type filter
    if (typeFilter != TransactionTypeFilter.all) {
      filtered = filtered.where((t) {
        if (typeFilter == TransactionTypeFilter.credit) {
          return t.type == TransactionType.income;
        } else {
          return t.type == TransactionType.expense;
        }
      }).toList();
    }

    // Apply category filter
    if (categoryFilter != null) {
      filtered = filtered.where((t) => t.categoryId == categoryFilter).toList();
    }

    // Apply recurring filter
    if (recurringFilter != RecurringFilter.all) {
      filtered = filtered.where((t) {
        if (recurringFilter == RecurringFilter.recurring) {
          return t.isRecurring;
        } else {
          return !t.isRecurring;
        }
      }).toList();
    }

    return filtered;
  }
}