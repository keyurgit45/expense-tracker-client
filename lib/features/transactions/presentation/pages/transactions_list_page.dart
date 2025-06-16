import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/injection.dart';
import '../bloc/transactions_list_cubit.dart';
import '../bloc/transactions_list_state.dart';
import '../../../../core/constants/color_constants.dart';
import '../widgets/filter_chip_widget.dart';
import '../widgets/transaction_list_with_dates.dart';

class TransactionsListPage extends StatelessWidget {
  const TransactionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransactionsListCubit>()..loadTransactions(),
      child: const TransactionsListView(),
    );
  }
}

class TransactionsListView extends StatelessWidget {
  const TransactionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.bgPrimary,
      appBar: AppBar(
        backgroundColor: ColorConstants.bgPrimary,
        title: Text(
          'All Transactions',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: ColorConstants.textPrimary),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocBuilder<TransactionsListCubit, TransactionsListState>(
              builder: (context, state) {
                if (state is TransactionsListLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is TransactionsListError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                if (state is TransactionsListLoaded) {
                  if (state.filteredTransactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: ColorConstants.textQuaternary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions found',
                            style: GoogleFonts.inter(
                              color: ColorConstants.textTertiary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: TransactionListWithDates(
                      transactions: state.filteredTransactions,
                      onTap: (transaction) {
                        // Navigate to transaction detail
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return BlocBuilder<TransactionsListCubit, TransactionsListState>(
      builder: (context, state) {
        if (state is! TransactionsListLoaded) {
          return const SizedBox(height: 60);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // First row: Type filter
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChipWidget(
                      label: 'All',
                      isSelected: state.typeFilter == TransactionTypeFilter.all,
                      onTap: () {
                        context.read<TransactionsListCubit>().filterByType(
                          TransactionTypeFilter.all,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChipWidget(
                      label: 'Credit',
                      isSelected: state.typeFilter == TransactionTypeFilter.credit,
                      icon: const Icon(
                        Icons.arrow_downward,
                        size: 16,
                        color: ColorConstants.textPrimary,
                      ),
                      onTap: () {
                        context.read<TransactionsListCubit>().filterByType(
                          TransactionTypeFilter.credit,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChipWidget(
                      label: 'Debit',
                      isSelected: state.typeFilter == TransactionTypeFilter.debit,
                      icon: const Icon(
                        Icons.arrow_upward,
                        size: 16,
                        color: ColorConstants.textTertiary,
                      ),
                      onTap: () {
                        context.read<TransactionsListCubit>().filterByType(
                          TransactionTypeFilter.debit,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Second row: Category filter
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChipWidget(
                      label: 'All Categories',
                      isSelected: state.categoryFilter == null,
                      onTap: () {
                        context.read<TransactionsListCubit>().filterByCategory(null);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...state.categories.map((category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChipWidget(
                        label: category.name,
                        isSelected: state.categoryFilter == category.id,
                        onTap: () {
                          context.read<TransactionsListCubit>().filterByCategory(
                            category.id,
                          );
                        },
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Third row: Recurring filter
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChipWidget(
                      label: 'All Types',
                      isSelected: state.recurringFilter == RecurringFilter.all,
                      onTap: () {
                        context.read<TransactionsListCubit>().filterByRecurring(
                          RecurringFilter.all,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChipWidget(
                      label: 'Recurring',
                      isSelected: state.recurringFilter == RecurringFilter.recurring,
                      icon: const Icon(
                        Icons.refresh,
                        size: 16,
                        color: ColorConstants.textSecondary,
                      ),
                      onTap: () {
                        context.read<TransactionsListCubit>().filterByRecurring(
                          RecurringFilter.recurring,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChipWidget(
                      label: 'One-time',
                      isSelected: state.recurringFilter == RecurringFilter.normal,
                      onTap: () {
                        context.read<TransactionsListCubit>().filterByRecurring(
                          RecurringFilter.normal,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}