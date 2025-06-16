import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../domain/entities/transaction.dart';

class TransactionItemV2 extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final bool isLoading;

  const TransactionItemV2({
    super.key,
    required this.transaction,
    this.onTap,
    this.isLoading = false,
  });

  factory TransactionItemV2.loading() {
    return TransactionItemV2(
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        highlightColor: ColorConstants.bgQuaternary.withOpacity(0.3),
        splashColor: ColorConstants.bgQuaternary.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Left: Transaction type indicator
              _buildTypeIndicator(isCredit),
              const SizedBox(width: 12),
              
              // Middle: Description and category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: GoogleFonts.inter(
                        color: ColorConstants.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.categoryName ?? 'Other',
                      style: GoogleFonts.inter(
                        color: ColorConstants.textTertiary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Right: Amount with credit/debit indicator
              _buildAmount(isCredit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ShimmerWidget.circular(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rectangular(width: 120, height: 16),
                const SizedBox(height: 4),
                ShimmerWidget.rectangular(width: 80, height: 14),
              ],
            ),
          ),
          ShimmerWidget.rectangular(width: 80, height: 20),
        ],
      ),
    );
  }

  Widget _buildTypeIndicator(bool isCredit) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isCredit 
            ? ColorConstants.surface2
            : ColorConstants.surface1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
        color: isCredit
            ? ColorConstants.textPrimary
            : ColorConstants.textSecondary,
        size: 20,
      ),
    );
  }

  Widget _buildAmount(bool isCredit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            if (isCredit) 
              Text(
                '+',
                style: GoogleFonts.robotoMono(
                  color: ColorConstants.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Text(
              CurrencyFormatter.format(transaction.amount),
              style: GoogleFonts.robotoMono(
                color: isCredit
                    ? ColorConstants.textPrimary
                    : ColorConstants.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          isCredit ? 'Credit' : 'Debit',
          style: GoogleFonts.inter(
            color: ColorConstants.textQuaternary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}