class MindfulnessExercise {
  final String id;
  final String title;
  final String description;
  final String type; // 'Deep Breathing', 'Focus Reset', 'Gratitude Reflection', 'Exam Anxiety Relief', 'Confidence Boost'
  final int durationSeconds;
  final List<String> steps;

  const MindfulnessExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.durationSeconds,
    required this.steps,
  });

  factory MindfulnessExercise.fromJson(Map<String, dynamic> json) {
    return MindfulnessExercise(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'Deep Breathing',
      durationSeconds: (json['durationSeconds'] as num? ?? 120).toInt(),
      steps: (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'durationSeconds': durationSeconds,
      'steps': steps,
    };
  }
}
