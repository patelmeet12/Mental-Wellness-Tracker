import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mental_wellness_tracker/core/theme/app_colors.dart';
import 'package:mental_wellness_tracker/core/theme/app_spacing.dart';
import 'package:mental_wellness_tracker/core/widgets/glass_card.dart';
import 'package:mental_wellness_tracker/core/widgets/custom_button.dart';
import 'package:mental_wellness_tracker/core/widgets/confirmation_dialog.dart';
import 'package:mental_wellness_tracker/core/localization/app_localizations.dart';
import 'package:mental_wellness_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:mental_wellness_tracker/features/journal/presentation/providers/journal_provider.dart';
import 'package:mental_wellness_tracker/features/journal/domain/entities/journal_entry.dart';

class JournalEntryScreen extends ConsumerStatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  final _textController = TextEditingController();
  String _selectedMood = 'Neutral';
  bool _isAnalyzing = false;

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Excellent', 'emoji': '😀', 'color': AppColors.excellent},
    {'label': 'Good', 'emoji': '🙂', 'color': AppColors.good},
    {'label': 'Neutral', 'emoji': '😐', 'color': AppColors.neutral},
    {'label': 'Stressed', 'emoji': '😟', 'color': AppColors.stressed},
    {'label': 'Overwhelmed', 'emoji': '😢', 'color': AppColors.overwhelmed},
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submitEntry(AppLocalizations local) async {
    final content = _textController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your thoughts before submitting.')),
      );
      return;
    }

    final profile = ref.read(onboardingProvider).valueOrNull;
    if (profile == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final entry = await ref.read(journalProvider.notifier).addEntry(
            content: content,
            mood: _selectedMood,
            studentProfile: {
              'examType': profile.examType,
              'targetExamDate': profile.targetExamDate.toIso8601String(),
              'dailyStudyHours': profile.dailyStudyHours,
              'currentStressLevel': profile.currentStressLevel,
            },
          );

      if (entry != null && mounted) {
        _textController.clear();
        setState(() {
          _selectedMood = 'Neutral';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.excellent,
            content: Text(local.entrySavedSuccess),
          ),
        );
        
        // Show the analysis immediately in a dialog
        if (entry.analysis != null) {
          _showAnalysisDialog(context, entry, local);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.overwhelmed,
            content: Text('${local.analysisError} ($e)'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _deleteEntry(BuildContext context, String id, AppLocalizations local) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Journal Entry',
      content: local.confirmingDeleteJournal,
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed) {
      await ref.read(journalProvider.notifier).deleteEntry(id);
    }
  }

  void _showAnalysisDialog(BuildContext context, JournalEntry entry, AppLocalizations local) {
    final theme = Theme.of(context);
    final analysis = entry.analysis;
    if (analysis == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: AppElevations.none,
        child: GlassCard(
          width: 600,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Emotional Report',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Text(
                  DateFormat('MMMM dd, yyyy - hh:mm a').format(entry.date),
                  style: theme.textTheme.bodyMedium,
                ),
                const Divider(height: AppSpacing.lg),
                
                // Scores Row
                Row(
                  children: [
                    _ScoreIndicator(label: 'Wellness', score: analysis.wellnessScore, color: AppColors.excellent),
                    _ScoreIndicator(label: 'Stress', score: analysis.stressScore, color: AppColors.overwhelmed),
                    _ScoreIndicator(label: 'Focus', score: analysis.focusScore, color: AppColors.primary),
                  ],
                ),
                AppSpacing.gapMD,

                // Triggers
                if (analysis.triggers.isNotEmpty) ...[
                  Text('Stress Triggers Detected:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  AppSpacing.gapXS,
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: analysis.triggers.map((trigger) {
                      return Chip(
                        backgroundColor: AppColors.overwhelmed.withOpacity(0.1),
                        side: const BorderSide(color: AppColors.overwhelmed, width: 0.5),
                        label: Text(
                          trigger,
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.overwhelmed, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                  AppSpacing.gapMD,
                ],

                // Summary
                Text(local.emotionalSummary, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                AppSpacing.gapXS,
                Text(analysis.emotionalSummary, style: theme.textTheme.bodyLarge),
                AppSpacing.gapMD,

                // Insights
                Text(local.keyInsights, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                AppSpacing.gapXS,
                ...analysis.insights.map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.insights, size: 16, color: AppColors.secondary),
                          AppSpacing.gapSM,
                          Expanded(child: Text(insight, style: theme.textTheme.bodyMedium)),
                        ],
                      ),
                    )),
                AppSpacing.gapMD,

                // Recommendations
                Text(local.recommendations, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                AppSpacing.gapXS,
                ...analysis.recommendations.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                          AppSpacing.gapSM,
                          Expanded(child: Text(rec, style: theme.textTheme.bodyMedium)),
                        ],
                      ),
                    )),
                AppSpacing.gapLG,
                
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    text: 'Close',
                    width: 100,
                    height: 38,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final entriesAsync = ref.watch(journalProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    Widget buildWritePane() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            local.journalTitle,
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.gapXS,
          Text(
            local.journalSubtitle,
            style: textTheme.bodyMedium,
          ),
          AppSpacing.gapLG,

          // Mood selector
          Text(local.moodCheckIn, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.gapSM,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['label'];
              final moodColor = mood['color'] as Color;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedMood = mood['label'];
                  });
                },
                borderRadius: AppRadius.borderMD,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected ? moodColor.withOpacity(0.15) : Colors.transparent,
                    borderRadius: AppRadius.borderMD,
                    border: Border.all(
                      color: isSelected ? moodColor : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mood['emoji'], style: const TextStyle(fontSize: 18)),
                      AppSpacing.gapXS,
                      Text(
                        mood['label'],
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? moodColor : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          AppSpacing.gapLG,

          // Journal content area
          Expanded(
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: TextFormField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: local.journalHint,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                ),
              ),
            ),
          ),
          AppSpacing.gapLG,

          CustomButton(
            text: local.submitJournal,
            icon: Icons.auto_awesome,
            width: double.infinity,
            isLoading: _isAnalyzing,
            onPressed: () => _submitEntry(local),
          ),
        ],
      );
    }

    Widget buildHistoryPane(List<JournalEntry> entries) {
      if (entries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_note, size: 64, color: AppColors.primary),
              AppSpacing.gapSM,
              Text('No reflections logged yet', style: textTheme.titleLarge),
              AppSpacing.gapXS,
              Text('Your written entries and AI analyses will appear here.', style: textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            local.historyTitle,
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.gapLG,
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final hasAnalysis = entry.analysis != null;
                final moodItem = _moods.firstWhere((e) => e['label'] == entry.mood, orElse: () => _moods[2]);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(moodItem['emoji'], style: const TextStyle(fontSize: 24)),
                            AppSpacing.gapSM,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('MMM dd, yyyy - hh:mm a').format(entry.date),
                                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Feeling ${entry.mood}',
                                    style: textTheme.bodyMedium?.copyWith(color: moodItem['color']),
                                  ),
                                ],
                              ),
                            ),
                            if (hasAnalysis)
                              IconButton(
                                icon: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                                tooltip: 'View AI report',
                                onPressed: () => _showAnalysisDialog(context, entry, local),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.overwhelmed, size: 20),
                              tooltip: 'Delete reflection',
                              onPressed: () => _deleteEntry(context, entry.id, local),
                            ),
                          ],
                        ),
                        AppSpacing.gapSM,
                        Text(
                          entry.content,
                          style: textTheme.bodyLarge,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hasAnalysis) ...[
                          AppSpacing.gapMD,
                          Row(
                            children: [
                              _ScoreBadge(label: 'Wellness: ${entry.analysis!.wellnessScore}', color: AppColors.excellent),
                              AppSpacing.gapXS,
                              _ScoreBadge(label: 'Stress: ${entry.analysis!.stressScore}', color: AppColors.overwhelmed),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('Error loading journals: $e')),
            data: (entries) {
              if (isDesktop) {
                return Row(
                  children: [
                    Expanded(flex: 3, child: buildWritePane()),
                    AppSpacing.gapXL,
                    Expanded(flex: 2, child: buildHistoryPane(entries)),
                  ],
                );
              } else {
                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Write Reflection', icon: const Icon(Icons.edit)),
                          Tab(text: 'History (${entries.length})', icon: const Icon(Icons.history)),
                        ],
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.primary,
                      ),
                      AppSpacing.gapLG,
                      Expanded(
                        child: TabBarView(
                          children: [
                            buildWritePane(),
                            buildHistoryPane(entries),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _ScoreIndicator extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreIndicator({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        color: color.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMD,
          side: BorderSide(color: color.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            children: [
              Text(
                '$score',
                style: textTheme.headlineLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
              AppSpacing.gapXXS,
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ScoreBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.borderXS,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
