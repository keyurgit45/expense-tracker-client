import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../../core/widgets/shimmer_widget.dart';

class CategoryButton extends StatelessWidget {
  final String name;
  final String icon;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const CategoryButton({
    super.key,
    required this.name,
    required this.icon,
    required this.backgroundColor,
    this.onTap,
    this.isLoading = false,
  });

  factory CategoryButton.loading() {
    return const CategoryButton(
      name: '',
      icon: '',
      backgroundColor: Colors.transparent,
      isLoading: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ShimmerWidget.rectangular(
        width: double.infinity,
        height: 80,
        borderRadius: 16,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: ColorConstants.borderSubtle),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.inter(
                color: ColorConstants.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}