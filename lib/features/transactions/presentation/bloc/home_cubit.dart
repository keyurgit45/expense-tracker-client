import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/services/category_service.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final TransactionRepository _transactionRepository;
  final CategoryService _categoryService;

  HomeCubit(this._transactionRepository, this._categoryService) : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());

    // Load account summary
    final summaryResult = await _transactionRepository.getAccountSummary();
    
    if (summaryResult.isLeft()) {
      emit(HomeError(
        message: summaryResult.fold(
          (failure) => failure.message,
          (_) => '',
        ),
      ));
      return;
    }

    // Load current month transactions
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final transactionsResult = await _transactionRepository.getTransactions(
      startDate: startOfMonth,
      endDate: endOfMonth,
      limit: 30,
    );

    if (transactionsResult.isLeft()) {
      emit(HomeError(
        message: transactionsResult.fold(
          (failure) => failure.message,
          (_) => '',
        ),
      ));
      return;
    }

    // Get top categories from transactions
    List<Category> topCategories = [];
    try {
      final categories = await _categoryService.getCategories();
      
      // Count category usage in transactions
      final categoryUsage = <String, int>{};
      for (final transaction in transactionsResult.getOrElse(() => [])) {
        if (transaction.categoryId != null) {
          categoryUsage[transaction.categoryId!] = 
              (categoryUsage[transaction.categoryId!] ?? 0) + 1;
        }
      }
      
      // Sort categories by usage and take top 3
      final sortedCategoryIds = categoryUsage.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      topCategories = sortedCategoryIds
          .take(3)
          .map((entry) => categories.firstWhere(
                (cat) => cat.id == entry.key,
                orElse: () => const Category(id: '', name: 'Other'),
              ))
          .where((cat) => cat.id.isNotEmpty)
          .toList();
      
      // If less than 3, add some default categories
      if (topCategories.length < 3) {
        final defaultCategories = categories
            .where((cat) => !topCategories.any((top) => top.id == cat.id))
            .take(3 - topCategories.length);
        topCategories.addAll(defaultCategories);
      }
    } catch (e) {
      // Use empty list if categories fail to load
      topCategories = [];
    }

    emit(HomeLoaded(
      accountSummary: summaryResult.getOrElse(() => throw Exception()),
      latestTransactions: transactionsResult.getOrElse(() => []),
      topCategories: topCategories,
    ));
  }

  void watchTransactions() {
    // For now, we'll use the watchLatestTransactions but filter in memory
    // In a real app, we'd create a new method to watch current month only
    _transactionRepository.watchLatestTransactions(limit: 30).listen(
      (result) {
        result.fold(
          (failure) => emit(HomeError(message: failure.message)),
          (transactions) {
            if (state is HomeLoaded) {
              final currentState = state as HomeLoaded;
              emit(HomeLoaded(
                accountSummary: currentState.accountSummary,
                latestTransactions: transactions,
                topCategories: currentState.topCategories,
              ));
            }
          },
        );
      },
    );
  }
}