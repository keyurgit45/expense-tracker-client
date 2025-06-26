import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/routes/app_router.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/widgets/expandable_fab.dart';
import '../widgets/balance_card.dart';
import '../widgets/greeting_widget.dart';
import '../widgets/income_expense_card.dart';
import '../widgets/transaction_list_with_dates.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHomeData();
    context.read<HomeCubit>().watchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.bgPrimary,
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().loadHomeData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const GreetingWidget(),
                          const SizedBox(height: 32),
                          BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, state) {
                              if (state is HomeLoaded) {
                                return BalanceCard(
                                  balance: state.accountSummary.totalBalance,
                                );
                              }
                              return const BalanceCard(
                                balance: 0,
                                isLoading: true,
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<HomeCubit, HomeState>(
                            builder: (context, state) {
                              if (state is HomeLoaded) {
                                return IncomeExpenseCard(
                                  income: state.accountSummary.totalIncome,
                                  expense: state.accountSummary.totalExpense,
                                  incomeChangePercent: state
                                      .accountSummary.incomeChangePercentage,
                                  expenseChangePercent: state
                                      .accountSummary.expenseChangePercentage,
                                );
                              }
                              return const IncomeExpenseCard(
                                income: 0,
                                expense: 0,
                                incomeChangePercent: 0,
                                expenseChangePercent: 0,
                                isLoading: true,
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    _buildTransactionsSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 45,
            left: 0,
            right: 0,
            child: Center(
              child: ExpandableFab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This month',
                    style: GoogleFonts.inter(
                      color: ColorConstants.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Transactions',
                    style: GoogleFonts.inter(
                      color: ColorConstants.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  context.push(AppRouter.transactions);
                },
                icon: const Icon(
                  Icons.chevron_right,
                  color: ColorConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoaded) {
              if (state.latestTransactions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: ColorConstants.textQuaternary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: GoogleFonts.inter(
                            color: ColorConstants.textTertiary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Calculate height based on available space
              final screenHeight = MediaQuery.of(context).size.height;
              final availableHeight = screenHeight -
                  400; // Approximate space taken by other widgets

              return SizedBox(
                height: availableHeight.clamp(400, 800), // Min 400, max 800
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: TransactionListWithDates(
                    transactions: state.latestTransactions,
                    onTap: (transaction) {
                      context.push('/transactions/${transaction.id}');
                    },
                  ),
                ),
              );
            }

            if (state is HomeError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: ColorConstants.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: GoogleFonts.inter(
                          color: ColorConstants.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return const TransactionListWithDatesLoading();
          },
        ),
      ],
    );
  }
}
