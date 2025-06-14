import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';

enum TransactionTypeFilter { all, credit, debit }
enum RecurringFilter { all, recurring, normal }

abstract class TransactionsListState extends Equatable {
  const TransactionsListState();

  @override
  List<Object?> get props => [];
}

class TransactionsListInitial extends TransactionsListState {}

class TransactionsListLoading extends TransactionsListState {}

class TransactionsListLoaded extends TransactionsListState {
  final List<Transaction> transactions;
  final List<Transaction> filteredTransactions;
  final List<Category> categories;
  final TransactionTypeFilter typeFilter;
  final String? categoryFilter;
  final RecurringFilter recurringFilter;

  const TransactionsListLoaded({
    required this.transactions,
    required this.filteredTransactions,
    required this.categories,
    this.typeFilter = TransactionTypeFilter.all,
    this.categoryFilter,
    this.recurringFilter = RecurringFilter.all,
  });

  @override
  List<Object?> get props => [
        transactions,
        filteredTransactions,
        categories,
        typeFilter,
        categoryFilter,
        recurringFilter,
      ];

  TransactionsListLoaded copyWith({
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    List<Category>? categories,
    TransactionTypeFilter? typeFilter,
    String? Function()? categoryFilter,
    RecurringFilter? recurringFilter,
  }) {
    return TransactionsListLoaded(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      categories: categories ?? this.categories,
      typeFilter: typeFilter ?? this.typeFilter,
      categoryFilter: categoryFilter != null ? categoryFilter() : this.categoryFilter,
      recurringFilter: recurringFilter ?? this.recurringFilter,
    );
  }
}

class TransactionsListError extends TransactionsListState {
  final String message;

  const TransactionsListError({required this.message});

  @override
  List<Object> get props => [message];
}