import 'package:equatable/equatable.dart';

import '../../domain/entities/account_summary.dart';
import '../../domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final AccountSummary accountSummary;
  final List<Transaction> latestTransactions;
  final List<Category> topCategories;

  const HomeLoaded({
    required this.accountSummary,
    required this.latestTransactions,
    required this.topCategories,
  });

  @override
  List<Object> get props => [
        accountSummary,
        latestTransactions,
        topCategories,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}