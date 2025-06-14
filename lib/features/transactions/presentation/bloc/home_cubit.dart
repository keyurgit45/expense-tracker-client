import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../categories/domain/entities/category.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final TransactionRepository _transactionRepository;

  HomeCubit(this._transactionRepository) : super(HomeInitial());

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

    // Load latest transactions
    final transactionsResult = await _transactionRepository.getLatestTransactions(
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

    // Mock top categories for now
    // In a real app, this would come from the category repository
    final topCategories = [
      const Category(
        id: '1',
        name: 'Shopping',
      ),
      const Category(
        id: '2',
        name: 'Food',
      ),
      const Category(
        id: '3',
        name: 'Others',
      ),
    ];

    emit(HomeLoaded(
      accountSummary: summaryResult.getOrElse(() => throw Exception()),
      latestTransactions: transactionsResult.getOrElse(() => []),
      topCategories: topCategories,
    ));
  }

  void watchTransactions() {
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