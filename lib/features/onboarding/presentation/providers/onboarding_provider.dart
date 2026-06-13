import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_wellness_tracker/features/onboarding/domain/entities/student_profile.dart';
import 'package:mental_wellness_tracker/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:mental_wellness_tracker/core/providers/core_providers.dart';

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, AsyncValue<StudentProfile?>>((ref) {
  final repo = ref.watch(onboardingRepositoryProvider);
  return OnboardingNotifier(repo);
});

class OnboardingNotifier extends StateNotifier<AsyncValue<StudentProfile?>> {
  final OnboardingRepository _repository;

  OnboardingNotifier(this._repository) : super(const AsyncValue.loading()) {
    checkProfile();
  }

  Future<void> checkProfile() async {
    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> saveProfile({
    required String name,
    required String examType,
    required DateTime targetExamDate,
    required double dailyStudyHours,
    required String currentStressLevel,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = StudentProfile(
        name: name,
        examType: examType,
        targetExamDate: targetExamDate,
        dailyStudyHours: dailyStudyHours,
        currentStressLevel: currentStressLevel,
      );
      await _repository.saveProfile(profile);
      state = AsyncValue.data(profile);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> clearProfile() async {
    state = const AsyncValue.loading();
    try {
      await _repository.clearProfile();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
