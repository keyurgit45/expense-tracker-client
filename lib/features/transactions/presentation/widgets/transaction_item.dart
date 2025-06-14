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
            _buildTag(transaction.tag),
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

  Widget _buildTag(TransactionTag tag) {
    final tagConfig = _getTagConfig(tag);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: tagConfig.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tagConfig.text,
        style: GoogleFonts.inter(
          color: ColorConstants.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  _TagConfig _getTagConfig(TransactionTag tag) {
    switch (tag) {
      case TransactionTag.fee:
        return _TagConfig('FEE', ColorConstants.surface2);
      case TransactionTag.sale:
        return _TagConfig('SALE', ColorConstants.surface3);
      case TransactionTag.refund:
        return _TagConfig('REFUND', ColorConstants.surface1);
      case TransactionTag.other:
        return _TagConfig('OTHER', ColorConstants.surface2);
    }
  }
}

class _TagConfig {
  final String text;
  final Color color;

  _TagConfig(this.text, this.color);
}