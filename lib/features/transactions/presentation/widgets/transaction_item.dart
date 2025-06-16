import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../domain/entities/transaction.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final bool isLoading;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.isLoading = false,
  });

  factory TransactionItem.loading() {
    return TransactionItem(
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            ShimmerWidget.rectangular(width: 60, height: 28, borderRadius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: ShimmerWidget.rectangular(width: 120, height: 20),
            ),
            ShimmerWidget.rectangular(width: 60, height: 20),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _buildCategory(transaction.categoryName),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                transaction.description,
                style: GoogleFonts.inter(
                  color: ColorConstants.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '₹${CurrencyFormatter.formatWithoutSymbol(transaction.amount)}',
              style: GoogleFonts.inter(
                color: transaction.type == TransactionType.income 
                    ? ColorConstants.textPrimary 
                    : ColorConstants.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String? categoryName) {
    final name = categoryName ?? 'Other';
    final color = _getCategoryColor(name);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name.toUpperCase(),
        style: GoogleFonts.inter(
          color: ColorConstants.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    // Use different surface colors based on category name hash
    final hash = categoryName.hashCode;
    final colors = [
      ColorConstants.surface1,
      ColorConstants.surface2,
      ColorConstants.surface3,
      ColorConstants.bgQuaternary,
    ];
    return colors[hash.abs() % colors.length];
  }
}