import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_constants.dart';
import '../../domain/entities/sms_transaction.dart';

class SmsFilterChips extends StatelessWidget {
  final TransactionType? selectedType;
  final Function(TransactionType?) onFilterChanged;

  const SmsFilterChips({
    super.key,
    required this.selectedType,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip(
            label: 'All',
            isSelected: selectedType == null,
            onTap: () => onFilterChanged(null),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Credit',
            isSelected: selectedType == TransactionType.credit,
            onTap: () => onFilterChanged(TransactionType.credit),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Debit',
            isSelected: selectedType == TransactionType.debit,
            onTap: () => onFilterChanged(TransactionType.debit),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? ColorConstants.textPrimary : ColorConstants.surface2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check,
                size: 16,
                color: ColorConstants.bgPrimary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? ColorConstants.bgPrimary
                    : ColorConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}