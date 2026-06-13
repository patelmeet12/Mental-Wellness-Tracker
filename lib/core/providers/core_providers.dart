import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../services/gemini_service.dart';

import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/journal/domain/repositories/journal_repository.dart';
import '../../features/journal/data/repositories/journal_repository_impl.dart';
import '../../features/coach/domain/repositories/coach_repository.dart';
import '../../features/coach/data/repositories/coach_repository_impl.dart';
import '../../features/mindfulness/domain/repositories/mindfulness_repository.dart';
import '../../features/mindfulness/data/repositories/mindfulness_repository_impl.dart';

// Will override in main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return GeminiService(storage);
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return OnboardingRepositoryImpl(storage);
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return JournalRepositoryImpl(storage);
});

final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final gemini = ref.watch(geminiServiceProvider);
  return CoachRepositoryImpl(storage, gemini);
});

final mindfulnessRepositoryProvider = Provider<MindfulnessRepository>((ref) {
  final gemini = ref.watch(geminiServiceProvider);
  return MindfulnessRepositoryImpl(gemini);
});
