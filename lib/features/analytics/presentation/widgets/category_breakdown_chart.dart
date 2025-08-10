import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/color_constants.dart';
import '../../domain/entities/category_analytics.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final List<CategoryAnalytics> categories;

  const CategoryBreakdownChart({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    // Take top 5 categories for the chart
    final topCategories = categories.take(5).toList();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Pie Chart
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                startDegreeOffset: -90,
                sections: _buildPieChartSections(topCategories),
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // Could add touch interactions here
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Legend
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: topCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final color = _getColorForIndex(index);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.categoryName,
                              style: GoogleFonts.inter(
                                color: ColorConstants.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${category.percentage.toStringAsFixed(1)}%',
                              style: GoogleFonts.inter(
                                color: ColorConstants.textTertiary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(List<CategoryAnalytics> categories) {
    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final color = _getColorForIndex(index);

      return PieChartSectionData(
        color: color,
        value: category.percentage,
        title: '',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 0),
      );
    }).toList();
  }

  Color _getColorForIndex(int index) {
    // Monochromatic color palette with different shades
    final colors = [
      ColorConstants.textPrimary,
      ColorConstants.textSecondary,
      ColorConstants.textTertiary,
      ColorConstants.textQuaternary,
      ColorConstants.divider,
    ];
    
    return colors[index % colors.length];
  }
}