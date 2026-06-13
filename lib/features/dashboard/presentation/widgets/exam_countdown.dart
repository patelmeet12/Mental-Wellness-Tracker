import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';

class ExamCountdown extends StatelessWidget {
  final DateTime targetExamDate;
  final String examType;

  const ExamCountdown({
    super.key,
    required this.targetExamDate,
    required this.examType,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(targetExamDate.year, targetExamDate.month, targetExamDate.day);
    final daysLeft = examDay.difference(today).inDays;
    
    // Fallback if the exam has passed
    final actualDaysLeft = daysLeft < 0 ? 0 : daysLeft;

    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: AppRadius.borderMD,
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          AppSpacing.gapMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$examType Countdown',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Exam Date: ${DateFormat('MMMM dd, yyyy').format(targetExamDate)}',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$actualDaysLeft',
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: actualDaysLeft < 30 ? AppColors.overwhelmed : AppColors.secondary,
                  fontSize: 36,
                ),
              ),
              Text(
                'days left',
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
