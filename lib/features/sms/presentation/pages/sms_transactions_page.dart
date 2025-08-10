import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/color_constants.dart';
import '../../domain/entities/sms_transaction.dart';
import '../bloc/sms_cubit.dart';
import '../bloc/sms_state.dart';
import '../widgets/sms_transaction_item.dart';
import '../widgets/sms_filter_chips.dart';
import 'add_transaction_from_sms_page.dart';

class SmsTransactionsPage extends StatefulWidget {
  const SmsTransactionsPage({super.key});

  @override
  State<SmsTransactionsPage> createState() => _SmsTransactionsPageState();
}

class _SmsTransactionsPageState extends State<SmsTransactionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SmsCubit>().loadSmsTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.bgPrimary,
      appBar: AppBar(
        backgroundColor: ColorConstants.bgPrimary,
        elevation: 0,
        title: Text(
          'SMS Transactions',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(
          color: ColorConstants.textPrimary,
        ),
      ),
      body: BlocBuilder<SmsCubit, SmsState>(
        builder: (context, state) {
          if (state is SmsLoading) {
            return _buildLoadingState();
          } else if (state is SmsPermissionDenied) {
            return _buildPermissionDeniedState();
          } else if (state is SmsError) {
            return _buildErrorState(state.message);
          } else if (state is SmsLoaded) {
            return _buildLoadedState(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: ColorConstants.textPrimary,
      ),
    );
  }

  Widget _buildPermissionDeniedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sms_failed,
              size: 64,
              color: ColorConstants.textQuaternary,
            ),
            const SizedBox(height: 16),
            Text(
              'SMS Permission Required',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please grant SMS permission to view your bank transactions',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: ColorConstants.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<SmsCubit>().loadSmsTransactions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.surface3,
                foregroundColor: ColorConstants.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Grant Permission',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: ColorConstants.textQuaternary,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading SMS',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: ColorConstants.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<SmsCubit>().loadSmsTransactions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.surface3,
                foregroundColor: ColorConstants.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(SmsLoaded state) {
    final transactions = state.filteredTransactions;

    if (transactions.isEmpty) {
      return _buildEmptyState(state.filterType != null);
    }

    // Group transactions by date
    final groupedTransactions = <String, List<SmsTransaction>>{};
    for (final transaction in transactions) {
      final dateKey = _getDateKey(transaction.date);
      groupedTransactions.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return Column(
      children: [
        // Filter chips
        SmsFilterChips(
          selectedType: state.filterType,
          onFilterChanged: (type) {
            context.read<SmsCubit>().filterByType(type);
          },
        ),
        // Transactions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: groupedTransactions.length,
            itemBuilder: (context, index) {
              final dateKey = groupedTransactions.keys.elementAt(index);
              final dateTransactions = groupedTransactions[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  if (index > 0) const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      dateKey,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (index > 0)
                    Container(
                      height: 1,
                      color: ColorConstants.borderSubtle,
                    ),
                  const SizedBox(height: 16),
                  // Transactions for this date
                  ...dateTransactions.map((transaction) {
                    return SmsTransactionItem(
                      transaction: transaction,
                      onAddToTransactions: () {
                        _navigateToAddTransaction(transaction);
                      },
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isFiltered) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.filter_list_off : Icons.inbox,
            size: 64,
            color: ColorConstants.textQuaternary,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered
                ? 'No transactions found for this filter'
                : 'No bank transactions found',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: ColorConstants.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  void _navigateToAddTransaction(SmsTransaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionFromSmsPage(
          smsTransaction: transaction,
        ),
      ),
    );
  }
}