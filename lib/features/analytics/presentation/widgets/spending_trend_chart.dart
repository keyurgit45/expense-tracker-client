import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/color_constants.dart';
import '../../domain/entities/spending_trend.dart';

class SpendingTrendChart extends StatelessWidget {
  final List<SpendingTrend> trends;

  const SpendingTrendChart({
    super.key,
    required this.trends,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorConstants.bgSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No trend data available',
            style: GoogleFonts.inter(
              color: ColorConstants.textTertiary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final maxAmount = trends.map((t) => t.amount).reduce((a, b) => a > b ? a : b);
    final minAmount = trends.map((t) => t.amount).reduce((a, b) => a < b ? a : b);
    final range = maxAmount - minAmount;
    final yInterval = range > 0 ? range / 4 : 1000;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval.toDouble(),
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: ColorConstants.divider,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < trends.length) {
                    final trend = trends[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _formatDateLabel(trend.date, trend.period),
                        style: GoogleFonts.inter(
                          color: ColorConstants.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: yInterval.toDouble(),
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatAmount(value),
                    style: GoogleFonts.inter(
                      color: ColorConstants.textTertiary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: trends.length - 1,
          minY: minAmount * 0.9,
          maxY: maxAmount * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: trends.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.amount);
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  ColorConstants.textPrimary.withOpacity(0.8),
                  ColorConstants.textPrimary,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: ColorConstants.textPrimary,
                    strokeWidth: 2,
                    strokeColor: ColorConstants.bgSecondary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    ColorConstants.textPrimary.withOpacity(0.1),
                    ColorConstants.textPrimary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => ColorConstants.bgTertiary,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  return LineTooltipItem(
                    '₹${NumberFormat('#,##,###').format(barSpot.y.toInt())}',
                    GoogleFonts.robotoMono(
                      color: ColorConstants.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateLabel(DateTime date, String period) {
    switch (period) {
      case 'day':
        return DateFormat('dd').format(date);
      case 'week':
        return DateFormat('MMM dd').format(date);
      case 'month':
        return DateFormat('MMM').format(date);
      default:
        return DateFormat('dd').format(date);
    }
  }

  String _formatAmount(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${value.toInt()}';
    }
  }
}