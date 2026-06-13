import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_wellness_tracker/core/theme/app_colors.dart';
import 'package:mental_wellness_tracker/core/theme/app_spacing.dart';
import 'package:mental_wellness_tracker/core/widgets/glass_card.dart';
import 'package:mental_wellness_tracker/core/widgets/custom_button.dart';
import 'package:mental_wellness_tracker/core/localization/app_localizations.dart';
import 'package:mental_wellness_tracker/features/journal/presentation/providers/journal_provider.dart';
import 'package:mental_wellness_tracker/features/analytics/presentation/widgets/mood_chart.dart';
import 'package:mental_wellness_tracker/features/analytics/presentation/widgets/stress_trend_chart.dart';
import 'package:mental_wellness_tracker/features/analytics/presentation/widgets/trigger_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final journalAsync = ref.watch(journalProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: journalAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('Error: $e')),
            data: (entries) {
              final analyzed = entries.where((e) => e.analysis != null).toList();

              if (entries.isEmpty || analyzed.isEmpty) {
                return Center(
                  child: GlassCard(
                    width: 500,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.insights,
                          size: 64,
                          color: AppColors.primary,
                        ),
                        AppSpacing.gapMD,
                        Text(
                          'AI Insights Locked',
                          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        AppSpacing.gapSM,
                        Text(
                          'Please log at least one reflection journal entry with AI analysis enabled to unlock detailed analytics reports and stress trigger detection.',
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.gapLG,
                        CustomButton(
                          text: 'Write Your First Entry',
                          width: 250,
                          onPressed: () => GoRouter.of(context).go('/journal'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Aggregate trigger occurrences
              final Map<String, int> triggersCount = {};
              for (final entry in analyzed) {
                for (final trigger in entry.analysis!.triggers) {
                  triggersCount[trigger] = (triggersCount[trigger] ?? 0) + 1;
                }
              }

              // General Wellness summary report based on latest entry
              final latestAnalysis = analyzed.first.analysis!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    local.navAnalytics,
                    style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.gapXS,
                  Text(
                    'Track emotional trends, monitor stress levels, and identify study triggers.',
                    style: textTheme.bodyMedium,
                  ),
                  AppSpacing.gapLG,

                  Expanded(
                    child: ListView(
                      children: [
                        // Latest Report Summary
                        GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.05),
                              AppColors.secondary.withOpacity(0.05),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                                  AppSpacing.gapSM,
                                  Text(
                                    'Latest Emotional Growth Summary',
                                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              AppSpacing.gapSM,
                              Text(
                                latestAnalysis.emotionalSummary,
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.gapLG,

                        // Charts & Triggers Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isDesktop ? 2 : 1,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: isDesktop ? 1.5 : 1.3,
                          children: [
                            MoodChart(entries: entries),
                            StressTrendChart(entries: entries),
                          ],
                        ),
                        AppSpacing.gapLG,

                        // Trigger Card
                        SizedBox(
                          height: 400,
                          child: TriggerCard(triggersData: triggersCount),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
