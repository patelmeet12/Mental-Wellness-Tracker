import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_wellness_tracker/core/providers/core_providers.dart';
import 'package:mental_wellness_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:mental_wellness_tracker/features/journal/presentation/providers/journal_provider.dart';

final dashboardMotivationProvider = FutureProvider<String>((ref) async {
  final profileAsync = ref.watch(onboardingProvider);
  final journalState = ref.watch(journalProvider);
  final gemini = ref.watch(geminiServiceProvider);

  final profile = profileAsync.valueOrNull;
  if (profile == null) return 'Believe in yourself. You have the capability to conquer your goals!';

  double wellnessScore = 75.0;
  if (journalState.valueOrNull != null) {
    final journalNotifier = ref.read(journalProvider.notifier);
    final scores = journalNotifier.getAverageScores();
    wellnessScore = scores['wellness'] ?? 75.0;
  }

  try {
    return await gemini.generateMotivationMessage({
      'examType': profile.examType,
      'dailyStudyHours': profile.dailyStudyHours,
      'currentStressLevel': profile.currentStressLevel,
    }, wellnessScore);
  } catch (_) {
    return 'Your focus and hard work today are paving the way for your success tomorrow. Keep believing in yourself!';
  }
});
