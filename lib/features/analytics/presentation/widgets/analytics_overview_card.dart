import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/color_constants.dart';
import '../../domain/entities/analytics_summary.dart';

class AnalyticsOverviewCard extends StatelessWidget {
  final AnalyticsSummary summary;

  const AnalyticsOverviewCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Column(
      children: [
        // Net Cash Flow
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorConstants.bgSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Net Cash Flow',
                style: GoogleFonts.inter(
                  color: ColorConstants.textTertiary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(summary.netCashFlow),
                style: GoogleFonts.robotoMono(
                  color: summary.netCashFlow >= 0
                      ? ColorConstants.success
                      : ColorConstants.error,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getPercentageText(
                  summary.netCashFlow,
                  summary.totalIncome - summary.totalExpense -
                      (summary.previousPeriodIncome - summary.previousPeriodExpense),
                ),
                style: GoogleFonts.inter(
                  color: ColorConstants.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Income and Expense Row
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Income',
                amount: summary.totalIncome,
                previousAmount: summary.previousPeriodIncome,
                currencyFormat: currencyFormat,
                isPositive: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: 'Expense',
                amount: summary.totalExpense,
                previousAmount: summary.previousPeriodExpense,
                currencyFormat: currencyFormat,
                isPositive: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Average Daily Spending and Transaction Count
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorConstants.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Avg Daily',
                      style: GoogleFonts.inter(
                        color: ColorConstants.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(summary.averageDailySpending),
                      style: GoogleFonts.robotoMono(
                        color: ColorConstants.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorConstants.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transactions',
                      style: GoogleFonts.inter(
                        color: ColorConstants.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.transactionCount}',
                      style: GoogleFonts.robotoMono(
                        color: ColorConstants.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double amount,
    required double previousAmount,
    required NumberFormat currencyFormat,
    required bool isPositive,
  }) {
    final changePercentage = previousAmount == 0
        ? 0.0
        : ((amount - previousAmount) / previousAmount) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: ColorConstants.textTertiary,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? ColorConstants.success.withOpacity(0.1)
                      : ColorConstants.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPositive ? 'IN' : 'OUT',
                  style: GoogleFonts.inter(
                    color: isPositive
                        ? ColorConstants.success
                        : ColorConstants.error,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(amount),
            style: GoogleFonts.robotoMono(
              color: ColorConstants.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${changePercentage >= 0 ? '↑' : '↓'} ${changePercentage.abs().toStringAsFixed(1)}%',
            style: GoogleFonts.inter(
              color: changePercentage >= 0
                  ? (isPositive ? ColorConstants.success : ColorConstants.error)
                  : (isPositive ? ColorConstants.error : ColorConstants.success),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getPercentageText(double current, double previous) {
    if (previous == 0) return 'No previous data';
    
    final percentage = ((current - previous) / previous.abs()) * 100;
    final isPositive = percentage >= 0;
    
    return '${isPositive ? '↑' : '↓'} ${percentage.abs().toStringAsFixed(1)}% vs last period';
  }
}