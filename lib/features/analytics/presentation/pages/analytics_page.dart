import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/injection.dart';
import '../../../../core/constants/color_constants.dart';
import '../bloc/analytics_cubit.dart';
import '../bloc/analytics_state.dart';
import '../widgets/analytics_overview_card.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/period_selector.dart';
import '../widgets/spending_trend_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AnalyticsCubit>()..loadAnalytics(),
      child: Scaffold(
        backgroundColor: ColorConstants.bgPrimary,
        appBar: AppBar(
          backgroundColor: ColorConstants.bgPrimary,
          elevation: 0,
          title: Text(
            'Analytics',
            style: GoogleFonts.inter(
              color: ColorConstants.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: const IconThemeData(color: ColorConstants.textPrimary),
        ),
        body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ColorConstants.textSecondary,
                ),
              );
            } else if (state is AnalyticsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: ColorConstants.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load analytics',
                      style: GoogleFonts.inter(
                        color: ColorConstants.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: GoogleFonts.inter(
                        color: ColorConstants.textTertiary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {
                        context.read<AnalyticsCubit>().loadAnalytics();
                      },
                      child: Text(
                        'Retry',
                        style: GoogleFonts.inter(
                          color: ColorConstants.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AnalyticsLoaded) {
              return CustomScrollView(
                slivers: [
                  // Period Selector
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: PeriodSelector(
                        selectedPeriod: state.selectedPeriod,
                        onPeriodChanged: (period) {
                          context.read<AnalyticsCubit>().changePeriod(period);
                        },
                      ),
                    ),
                  ),

                  // Overview Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AnalyticsOverviewCard(summary: state.summary),
                    ),
                  ),

                  // Category Breakdown
                  if (state.categoryAnalytics.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category Breakdown',
                              style: GoogleFonts.inter(
                                color: ColorConstants.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CategoryBreakdownChart(
                              categories: state.categoryAnalytics,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Spending Trends
                  if (state.spendingTrends.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spending Trends',
                              style: GoogleFonts.inter(
                                color: ColorConstants.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SpendingTrendChart(
                              trends: state.spendingTrends,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                ],
              );
            }

            return const Center(
              child: Text('No data available'),
            );
          },
        ),
      ),
    );
  }
}