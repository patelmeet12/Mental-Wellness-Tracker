import '../entities/mindfulness_exercise.dart';

abstract class MindfulnessRepository {
  List<MindfulnessExercise> getDefaultExercises();
  Future<MindfulnessExercise> generateCustomExercise(String type, Map<String, dynamic> studentProfile);
  Future<String> getMotivationalQuote(Map<String, dynamic> studentProfile, double wellnessScore);
}
