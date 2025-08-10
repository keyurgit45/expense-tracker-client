import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_constants.dart';
import '../bloc/analytics_state.dart';

class PeriodSelector extends StatelessWidget {
  final AnalyticsPeriod selectedPeriod;
  final Function(AnalyticsPeriod) onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPeriodChip(
            context,
            'Today',
            AnalyticsPeriod.today,
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(
            context,
            'This Month',
            AnalyticsPeriod.thisMonth,
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(
            context,
            'Last Month',
            AnalyticsPeriod.lastMonth,
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(
            context,
            'Last 3 Months',
            AnalyticsPeriod.lastThreeMonths,
          ),
          const SizedBox(width: 8),
          _buildPeriodChip(
            context,
            'Custom',
            AnalyticsPeriod.custom,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(
    BuildContext context,
    String label,
    AnalyticsPeriod period,
  ) {
    final isSelected = selectedPeriod == period;
    
    return GestureDetector(
      onTap: () => onPeriodChanged(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.textPrimary
              : ColorConstants.bgSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ColorConstants.textPrimary
                : ColorConstants.divider,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected
                  ? ColorConstants.bgPrimary
                  : ColorConstants.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}