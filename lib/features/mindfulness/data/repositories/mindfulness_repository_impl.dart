import '../../domain/entities/mindfulness_exercise.dart';
import '../../domain/repositories/mindfulness_repository.dart';
import '../../../../core/services/gemini_service.dart';

class MindfulnessRepositoryImpl implements MindfulnessRepository {
  final GeminiService _geminiService;

  MindfulnessRepositoryImpl(this._geminiService);

  @override
  List<MindfulnessExercise> getDefaultExercises() {
    return const [
      MindfulnessExercise(
        id: 'default_breathing',
        title: 'Box Breathing (4-4-4-4)',
        description: 'Calm your nervous system, reset focus, and reduce immediate exam stress.',
        type: 'Deep Breathing',
        durationSeconds: 120,
        steps: [
          'Inhale slowly through your nose for 4 seconds.',
          'Hold your breath comfortably for 4 seconds.',
          'Exhale completely through your mouth for 4 seconds.',
          'Hold empty for 4 seconds. Repeat the cycle.'
        ],
      ),
      MindfulnessExercise(
        id: 'default_focus',
        title: '5-4-3-2-1 Grounding Method',
        description: 'Pull your mind back to the present moment when study fatigue kicks in.',
        type: 'Focus Reset',
        durationSeconds: 180,
        steps: [
          'Acknowledge 5 things you can see around you.',
          'Acknowledge 4 things you can touch or feel physically.',
          'Acknowledge 3 things you can hear in your environment.',
          'Acknowledge 2 things you can smell.',
          'Acknowledge 1 thing you can taste.'
        ],
      ),
      MindfulnessExercise(
        id: 'default_gratitude',
        title: 'Gratitude Writing Reflection',
        description: 'Cultivate positivity by writing and reflecting on what went well today.',
        type: 'Gratitude Reflection',
        durationSeconds: 150,
        steps: [
          'Think of 3 small things you are grateful for today.',
          'Visualize why these things brought you comfort or happiness.',
          'Write them down in your thoughts. Realize you are making progress.'
        ],
      ),
      MindfulnessExercise(
        id: 'default_anxiety',
        title: 'Anxiety Release Progressive Relaxation',
        description: 'Release physical tension caused by long study hours.',
        type: 'Exam Anxiety Relief',
        durationSeconds: 240,
        steps: [
          'Sit comfortably and tense your shoulder muscles for 5 seconds.',
          'Release the tension suddenly and feel the weight drop.',
          'Tense your calf and leg muscles, then let go.',
          'Focus on your breathing, repeating: "I am prepared. I am calm."'
        ],
      ),
    ];
  }

  @override
  Future<MindfulnessExercise> generateCustomExercise(String type, Map<String, dynamic> studentProfile) async {
    try {
      final json = await _geminiService.generateMindfulnessExercise(type, studentProfile);
      return MindfulnessExercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Custom $type Exercise',
        description: json['description'] as String? ?? 'A personalized exercise designed for your exam preparation.',
        type: type,
        durationSeconds: (json['durationSeconds'] as num? ?? 120).toInt(),
        steps: (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      );
    } catch (e) {
      // Fallback to a matching default exercise
      final defaults = getDefaultExercises();
      final matched = defaults.firstWhere(
        (element) => element.type == type,
        orElse: () => defaults.first,
      );
      return matched;
    }
  }

  @override
  Future<String> getMotivationalQuote(Map<String, dynamic> studentProfile, double wellnessScore) async {
    try {
      return await _geminiService.generateMotivationMessage(studentProfile, wellnessScore);
    } catch (_) {
      return 'Your focus and hard work today are paving the way for your success tomorrow. Keep believing in yourself!';
    }
  }
}
