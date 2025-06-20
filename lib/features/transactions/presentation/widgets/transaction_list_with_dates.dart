import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/color_constants.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_item_minimal.dart';

class TransactionListWithDates extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onTap;

  const TransactionListWithDates({
    super.key,
    required this.transactions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildTransactionsList(),
    );
  }

  List<Widget> _buildTransactionsList() {
    final widgets = <Widget>[];
    String? lastDate;

    for (int i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];
      final currentDate = _formatDate(transaction.date);

      // Add date header if date changed
      if (currentDate != lastDate) {
        if (widgets.isNotEmpty) {
          widgets.add(const SizedBox(height: 24));
          widgets.add(Container(
            height: 1,
            color: ColorConstants.borderSubtle,
          ));
          widgets.add(const SizedBox(height: 16));
        }
        widgets.add(_buildDateHeader(currentDate));
        widgets.add(const SizedBox(height: 8));
        lastDate = currentDate;
      }

      widgets.add(TransactionItemMinimal(
        transaction: transaction,
        onTap: () => onTap(transaction),
      ));

      // Remove spacing between items for cleaner look
    }

    return widgets;
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        date,
        style: GoogleFonts.inter(
          color: ColorConstants.textTertiary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else if (transactionDate.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE').format(date); // Day name
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}

class TransactionListWithDatesLoading extends StatelessWidget {
  const TransactionListWithDatesLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeaderShimmer(),
        const SizedBox(height: 12),
        ...List.generate(5, (index) => Column(
          children: [
            TransactionItemMinimal.loading(),
            if (index < 4) const SizedBox(height: 8),
          ],
        )),
        const SizedBox(height: 16),
        _buildDateHeaderShimmer(),
        const SizedBox(height: 12),
        ...List.generate(5, (index) => Column(
          children: [
            TransactionItemMinimal.loading(),
            if (index < 4) const SizedBox(height: 8),
          ],
        )),
      ],
    );
  }

  Widget _buildDateHeaderShimmer() {
    return Container(
      width: 80,
      height: 16,
      decoration: BoxDecoration(
        color: ColorConstants.surface1,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}