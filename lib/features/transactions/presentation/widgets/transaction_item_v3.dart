import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../domain/entities/transaction.dart';

class TransactionItemV3 extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final bool isLoading;

  const TransactionItemV3({
    super.key,
    required this.transaction,
    this.onTap,
    this.isLoading = false,
  });

  factory TransactionItemV3.loading() {
    return TransactionItemV3(
      transaction: Transaction(
        id: '',
        description: '',
        amount: 0,
        type: TransactionType.expense,
        tag: TransactionTag.other,
        date: DateTime.now(),
      ),
      isLoading: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    final isCredit = transaction.type == TransactionType.income;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: ColorConstants.surface1,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          highlightColor: ColorConstants.bgQuaternary.withOpacity(0.3),
          splashColor: ColorConstants.bgQuaternary.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Merchant name
                    Expanded(
                      child: Text(
                        transaction.description,
                        style: GoogleFonts.inter(
                          color: ColorConstants.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Amount
                    Text(
                      '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                      style: GoogleFonts.robotoMono(
                        color: isCredit
                            ? ColorConstants.positive
                            : ColorConstants.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColorConstants.bgQuaternary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        transaction.categoryName ?? 'Other',
                        style: GoogleFonts.inter(
                          color: ColorConstants.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Transaction type
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCredit
                            ? ColorConstants.positiveSubtle
                            : ColorConstants.negativeSubtle,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isCredit ? 'CREDIT' : 'DEBIT',
                        style: GoogleFonts.inter(
                          color: ColorConstants.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Recurring indicator
                    if (transaction.isRecurring)
                      Icon(
                        Icons.repeat,
                        color: ColorConstants.textQuaternary,
                        size: 16,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorConstants.surface1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ShimmerWidget.rectangular(width: 150, height: 18),
                ),
                ShimmerWidget.rectangular(width: 100, height: 18),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ShimmerWidget.rectangular(width: 80, height: 24, borderRadius: 6),
                const SizedBox(width: 8),
                ShimmerWidget.rectangular(width: 60, height: 24, borderRadius: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}