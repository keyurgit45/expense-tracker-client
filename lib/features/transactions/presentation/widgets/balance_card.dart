import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/shimmer_widget.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final bool isLoading;

  const BalanceCard({
    super.key,
    required this.balance,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget.rectangular(width: 120, height: 16),
          const SizedBox(height: 8),
          ShimmerWidget.rectangular(width: 200, height: 36),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your total balance',
          style: GoogleFonts.inter(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(balance),
          style: GoogleFonts.inter(
            color: ColorConstants.textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}