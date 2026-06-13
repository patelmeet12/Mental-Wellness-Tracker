import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_wellness_tracker/core/theme/app_colors.dart';
import 'package:mental_wellness_tracker/core/theme/app_spacing.dart';
import 'package:mental_wellness_tracker/core/widgets/glass_card.dart';
import 'package:mental_wellness_tracker/core/localization/app_localizations.dart';
import 'package:mental_wellness_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:mental_wellness_tracker/features/journal/presentation/providers/journal_provider.dart';
import 'package:mental_wellness_tracker/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mental_wellness_tracker/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:mental_wellness_tracker/features/dashboard/presentation/widgets/exam_countdown.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final profileAsync = ref.watch(onboardingProvider);
    final journalAsync = ref.watch(journalProvider);
    final motivationAsync = ref.watch(dashboardMotivationProvider);

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: Text('Error: $e')),
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('No profile. Redirecting...'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card & Motivation Header
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.secondary.withOpacity(0.05),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${local.welcomeBack}, ${profile.name}! 👋',
                                style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              AppSpacing.gapSM,
                              motivationAsync.when(
                                loading: () => const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                error: (_, __) => Text(
                                  'Your focus today is building the success of tomorrow. Keep going!',
                                  style: textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                                ),
                                data: (quote) => Text(
                                  '"$quote"',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapLG,

                  // Scores Grid
                  journalAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, __) => Center(child: Text('Error: $e')),
                    data: (entries) {
                      final averages = ref.read(journalProvider.notifier).getAverageScores();
                      final streaks = ref.read(journalProvider.notifier).getStreaks();

                      final wellness = (averages['wellness'] ?? 75.0).toInt();
                      final stress = (averages['stress'] ?? 35.0).toInt();
                      final focus = (averages['focus'] ?? 80.0).toInt();

                      final screenWidth = MediaQuery.of(context).size.width;
                      final isMobile = screenWidth < 768;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Grid Layout for Scores
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: isMobile ? 1 : 3,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: isMobile ? 1.5 : 1.1,
                            children: [
                              MetricCard(
                                title: local.wellnessScore,
                                score: wellness,
                                color: AppColors.excellent,
                                icon: Icons.sentiment_satisfied_alt_outlined,
                              ),
                              MetricCard(
                                title: local.stressScore,
                                score: stress,
                                color: AppColors.overwhelmed,
                                icon: Icons.warning_amber_rounded,
                              ),
                              MetricCard(
                                title: local.focusScore,
                                score: focus,
                                color: AppColors.primary,
                                icon: Icons.track_changes_outlined,
                              ),
                            ],
                          ),
                          AppSpacing.gapLG,

                          // Countdown & Streaks Row
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: isMobile ? 1 : 2,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: isMobile ? 2.5 : 3.0,
                            children: [
                              ExamCountdown(
                                targetExamDate: profile.targetExamDate,
                                examType: profile.examType,
                              ),
                              // Streaks Card
                              GlassCard(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withOpacity(0.15),
                                        borderRadius: AppRadius.borderMD,
                                      ),
                                      child: const Icon(
                                        Icons.local_fire_department,
                                        color: AppColors.secondary,
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
                                            local.streaksTitle,
                                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Keep writing reflections to maintain your streak!',
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
                                          '${streaks['journal']}',
                                          style: textTheme.headlineLarge?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.secondary,
                                            fontSize: 36,
                                          ),
                                        ),
                                        Text(
                                          local.days,
                                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapLG,

                          // Quick Actions & Mood Summary Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: isMobile ? 1 : 2,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: isMobile ? 1.4 : 1.8,
                            children: [
                              // Quick Actions
                              GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      local.quickActions,
                                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    AppSpacing.gapMD,
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _QuickActionRow(
                                            title: local.addJournalEntry,
                                            icon: Icons.book,
                                            color: AppColors.primary,
                                            onTap: () => context.go('/journal'),
                                          ),
                                          _QuickActionRow(
                                            title: local.talkToCoach,
                                            icon: Icons.forum,
                                            color: AppColors.secondary,
                                            onTap: () => context.go('/coach'),
                                          ),
                                          _QuickActionRow(
                                            title: local.takeMindfulnessBreak,
                                            icon: Icons.spa,
                                            color: AppColors.excellent,
                                            onTap: () => context.go('/mindfulness'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Mood Summary
                              GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      local.moodSummary,
                                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    AppSpacing.gapMD,
                                    Expanded(
                                      child: entries.isEmpty
                                          ? Center(
                                              child: Text(
                                                'No mood history found. Write a reflection to track your mood!',
                                                style: textTheme.bodyMedium,
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          : _buildMoodSummaryList(entries, textTheme),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMoodSummaryList(List<dynamic> entries, TextTheme textTheme) {
    final total = entries.length;
    final Map<String, int> moodCounts = {
      'Excellent': 0,
      'Good': 0,
      'Neutral': 0,
      'Stressed': 0,
      'Overwhelmed': 0,
    };

    for (final e in entries) {
      if (moodCounts.containsKey(e.mood)) {
        moodCounts[e.mood] = moodCounts[e.mood]! + 1;
      }
    }

    final emojis = {
      'Excellent': '😀',
      'Good': '🙂',
      'Neutral': '😐',
      'Stressed': '😟',
      'Overwhelmed': '😢',
    };

    final colors = {
      'Excellent': AppColors.excellent,
      'Good': AppColors.good,
      'Neutral': AppColors.neutral,
      'Stressed': AppColors.stressed,
      'Overwhelmed': AppColors.overwhelmed,
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moodCounts.entries.where((element) => element.value > 0).map((entry) {
        final percentage = (entry.value / total);
        final color = colors[entry.key] ?? AppColors.neutral;
        final emoji = emojis[entry.key] ?? '😐';

        return Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            AppSpacing.gapSM,
            SizedBox(
              width: 100,
              child: Text(
                entry.key,
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: AppRadius.borderXS,
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 8,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            AppSpacing.gapSM,
            Text(
              '${(percentage * 100).toInt()}%',
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionRow({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderSM,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: AppRadius.borderSM,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            AppSpacing.gapMD,
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
