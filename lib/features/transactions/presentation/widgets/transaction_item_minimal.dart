import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../domain/entities/transaction.dart';

class TransactionItemMinimal extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final bool isLoading;

  const TransactionItemMinimal({
    super.key,
    required this.transaction,
    this.onTap,
    this.isLoading = false,
  });

  factory TransactionItemMinimal.loading() {
    return TransactionItemMinimal(
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
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: Merchant and category
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: GoogleFonts.inter(
                        color: ColorConstants.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Category with fixed width for alignment
                        SizedBox(
                          width: 100,
                          child: Text(
                            transaction.categoryName ?? 'Other',
                            style: GoogleFonts.inter(
                              color: ColorConstants.textTertiary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (transaction.isRecurring) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.refresh,
                            color: ColorConstants.textQuaternary,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Right side: Amount with type indicator
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Plus/minus indicator
                      Container(
                        width: 20,
                        alignment: Alignment.centerRight,
                        child: Text(
                          isCredit ? '+' : '-',
                          style: GoogleFonts.robotoMono(
                            color: isCredit
                                ? ColorConstants.positive
                                : ColorConstants.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Amount
                      Text(
                        CurrencyFormatter.format(transaction.amount),
                        style: GoogleFonts.robotoMono(
                          color: ColorConstants.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Small type indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCredit
                          ? ColorConstants.positiveSubtle.withOpacity(0.5)
                          : ColorConstants.surface2,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isCredit ? 'IN' : 'OUT',
                      style: GoogleFonts.inter(
                        color: ColorConstants.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerWidget.rectangular(width: 140, height: 16),
                const SizedBox(height: 4),
                ShimmerWidget.rectangular(width: 80, height: 14),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerWidget.rectangular(width: 100, height: 16),
              const SizedBox(height: 4),
              ShimmerWidget.rectangular(width: 40, height: 16, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}