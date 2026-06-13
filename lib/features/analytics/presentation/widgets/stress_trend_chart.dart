import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mental_wellness_tracker/core/theme/app_colors.dart';
import 'package:mental_wellness_tracker/core/theme/app_spacing.dart';
import 'package:mental_wellness_tracker/core/widgets/glass_card.dart';
import 'package:mental_wellness_tracker/features/journal/domain/entities/journal_entry.dart';

class StressTrendChart extends StatelessWidget {
  final List<JournalEntry> entries;

  const StressTrendChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final analyzedEntries = entries.where((e) => e.analysis != null).toList().reversed.toList();

    if (analyzedEntries.isEmpty) {
      return const SizedBox();
    }

    // Grab up to last 7 entries for trends
    final dataEntries = analyzedEntries.length > 7
        ? analyzedEntries.sublist(analyzedEntries.length - 7)
        : analyzedEntries;

    final List<FlSpot> spots = [];
    for (int i = 0; i < dataEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), dataEntries[i].analysis!.stressScore.toDouble()));
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stress Score Trajectory',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.show_chart, color: AppColors.overwhelmed, size: 20),
            ],
          ),
          AppSpacing.gapLG,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md, top: AppSpacing.sm),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark ? AppColors.darkBorder.withOpacity(0.3) : AppColors.lightBorder.withOpacity(0.5),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: textTheme.bodyMedium?.copyWith(fontSize: 10),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < dataEntries.length) {
                            final date = dataEntries[idx].date;
                            return Text(
                              DateFormat('dd/MM').format(date),
                              style: textTheme.bodyMedium?.copyWith(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (dataEntries.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: AppColors.stressGradient,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.overwhelmed,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.overwhelmed.withOpacity(0.2),
                            AppColors.overwhelmed.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
