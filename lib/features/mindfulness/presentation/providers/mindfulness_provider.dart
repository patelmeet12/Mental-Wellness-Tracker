import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_wellness_tracker/features/mindfulness/domain/entities/mindfulness_exercise.dart';
import 'package:mental_wellness_tracker/features/mindfulness/domain/repositories/mindfulness_repository.dart';
import 'package:mental_wellness_tracker/core/providers/core_providers.dart';

final mindfulnessProvider = StateNotifierProvider<MindfulnessNotifier, AsyncValue<List<MindfulnessExercise>>>((ref) {
  final repo = ref.watch(mindfulnessRepositoryProvider);
  return MindfulnessNotifier(repo);
});

class MindfulnessNotifier extends StateNotifier<AsyncValue<List<MindfulnessExercise>>> {
  final MindfulnessRepository _repository;

  MindfulnessNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadExercises();
  }

  void loadExercises() {
    try {
      final defaults = _repository.getDefaultExercises();
      state = AsyncValue.data(defaults);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<MindfulnessExercise> generateCustom({
    required String type,
    required Map<String, dynamic> studentProfile,
  }) async {
    final currentList = state.valueOrNull ?? [];
    
    try {
      final custom = await _repository.generateCustomExercise(type, studentProfile);
      
      // Prepend the custom exercise to the list
      state = AsyncValue.data([custom, ...currentList]);
      return custom;
    } catch (e) {
      rethrow;
    }
  }
}
