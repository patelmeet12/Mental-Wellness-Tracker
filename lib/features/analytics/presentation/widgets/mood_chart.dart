import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mental_wellness_tracker/core/theme/app_colors.dart';
import 'package:mental_wellness_tracker/core/theme/app_spacing.dart';
import 'package:mental_wellness_tracker/core/widgets/glass_card.dart';
import 'package:mental_wellness_tracker/features/journal/domain/entities/journal_entry.dart';

class MoodChart extends StatelessWidget {
  final List<JournalEntry> entries;

  const MoodChart({super.key, required this.entries});

  int _getMoodValue(String mood) {
    switch (mood) {
      case 'Excellent':
        return 5;
      case 'Good':
        return 4;
      case 'Neutral':
        return 3;
      case 'Stressed':
        return 2;
      case 'Overwhelmed':
        return 1;
      default:
        return 3;
    }
  }

  String _getMoodEmoji(int val) {
    switch (val) {
      case 5:
        return '😀';
      case 4:
        return '🙂';
      case 3:
        return '😐';
      case 2:
        return '😟';
      case 1:
        return '😢';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final reversedEntries = entries.reversed.toList();

    if (reversedEntries.isEmpty) {
      return const SizedBox();
    }

    final dataEntries = reversedEntries.length > 7
        ? reversedEntries.sublist(reversedEntries.length - 7)
        : reversedEntries;

    final List<FlSpot> spots = [];
    for (int i = 0; i < dataEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), _getMoodValue(dataEntries[i].mood).toDouble()));
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mood History Timeline',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.mood, color: AppColors.primary, size: 20),
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
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final val = value.toInt();
                          if (val >= 1 && val <= 5) {
                            return Center(
                              child: Text(
                                _getMoodEmoji(val),
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }
                          return const Text('');
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
                  minY: 1,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: AppColors.primaryGradient,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            AppColors.primary.withOpacity(0.0),
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
