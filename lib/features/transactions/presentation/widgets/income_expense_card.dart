import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/shimmer_widget.dart';

class IncomeExpenseCard extends StatelessWidget {
  final double income;
  final double expense;
  final double incomeChangePercent;
  final double expenseChangePercent;
  final bool isLoading;

  const IncomeExpenseCard({
    super.key,
    required this.income,
    required this.expense,
    required this.incomeChangePercent,
    required this.expenseChangePercent,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ShimmerWidget.rectangular(
          width: double.infinity,
          height: 100,
          borderRadius: 12,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.surface1,
        border: Border.all(color: ColorConstants.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSection(
              icon: Icons.arrow_upward,
              title: 'Income',
              amount: income,
              changePercent: incomeChangePercent,
              isPositive: true,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: ColorConstants.borderSubtle,
          ),
          Expanded(
            child: _buildSection(
              icon: Icons.arrow_downward,
              title: 'Expense',
              amount: expense,
              changePercent: expenseChangePercent,
              isPositive: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required double amount,
    required double changePercent,
    required bool isPositive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: isPositive ? -0.785398 : 0.785398, // 45 degrees
              child: Icon(
                icon,
                color: isPositive ? ColorConstants.textPrimary : ColorConstants.textTertiary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                color: ColorConstants.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          CurrencyFormatter.format(amount),
          style: GoogleFonts.inter(
            color: ColorConstants.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isPositive 
                ? (changePercent >= 0 ? ColorConstants.surface3 : ColorConstants.surface2)
                : (changePercent >= 0 ? ColorConstants.surface2 : ColorConstants.surface3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
            style: GoogleFonts.inter(
              color: ColorConstants.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}