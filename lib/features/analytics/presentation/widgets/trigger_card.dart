import 'package:flutter/material.dart';
import 'package:mental_wellness_tracker/core/theme/app_colors.dart';
import 'package:mental_wellness_tracker/core/theme/app_spacing.dart';
import 'package:mental_wellness_tracker/core/widgets/glass_card.dart';

class TriggerCard extends StatelessWidget {
  final Map<String, int> triggersData;

  const TriggerCard({super.key, required this.triggersData});

  String _getTriggerInsight(String trigger) {
    switch (trigger) {
      case 'Exam Pressure':
        return 'Often caused by unrealistic mock exam expectations. Try dividing your prep syllabus into micro-modules and taking timed breaks.';
      case 'Poor Sleep':
        return 'Late-night study sessions degrade memory retention. Set a hard cutoff at 11:00 PM and practice a 10-minute digital wind-down.';
      case 'Social Comparison':
        return 'Comparing mock scores with peers boosts cortisol. Focus strictly on your personal growth logs rather than peer benchmarks.';
      case 'Family Expectations':
        return 'Perceived pressure to succeed. Try talking openly with your family about your effort levels and stress, or request study-free conversations.';
      case 'Time Management':
        return 'Over-planning leads to execution paralysis. Try Box Scheduling and focus on finishing high-yield topics first.';
      case 'Fear of Failure':
        return 'Fear of negative outcomes. Practice focus breathing and reframe exams as learning benchmarks rather than final verdicts.';
      default:
        return 'Recognizing this stressor is the first step. Incorporate mindful breaks and stay consistent with daily study logs.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sortedTriggers = triggersData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Stress Trigger Analysis',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.flash_on, color: AppColors.stressed, size: 20),
            ],
          ),
          AppSpacing.gapSM,
          Text(
            'Identified recurring stressors from your reflections:',
            style: textTheme.bodyMedium,
          ),
          AppSpacing.gapMD,
          if (sortedTriggers.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No stress triggers detected yet. Write more journal entries with details of your prep stressors.',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: sortedTriggers.length,
                itemBuilder: (context, index) {
                  final entry = sortedTriggers[index];
                  final triggerName = entry.key;
                  final count = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Card(
                      color: AppColors.primary.withOpacity(0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMD,
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.darkBorder.withOpacity(0.3) 
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  triggerName,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.overwhelmed,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.overwhelmed.withOpacity(0.1),
                                    borderRadius: AppRadius.borderXS,
                                  ),
                                  child: Text(
                                    'Logged $count ${count == 1 ? "time" : "times"}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.overwhelmed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.gapXS,
                            Text(
                              _getTriggerInsight(triggerName),
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
