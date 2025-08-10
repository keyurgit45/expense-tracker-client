import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/services/category_service.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import 'transactions_list_state.dart';

class TransactionsListCubit extends Cubit<TransactionsListState> {
  final TransactionRepository _transactionRepository;
  final CategoryService _categoryService;

  TransactionsListCubit(this._transactionRepository, this._categoryService) : super(TransactionsListInitial());

  Future<void> refreshTransactions() async {
    await loadTransactions();
  }

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
    
    // Get categories from the service
    List<Category> categories;
    try {
      categories = await _categoryService.getCategories();
    } catch (e) {
      emit(TransactionsListError(message: 'Failed to load categories: $e'));
      return;
    }

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