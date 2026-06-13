class JournalEntry {
  final String id;
  final DateTime date;
  final String content;
  final String mood; // 'Excellent', 'Good', 'Neutral', 'Stressed', 'Overwhelmed'
  final JournalAnalysis? analysis;

  const JournalEntry({
    required this.id,
    required this.date,
    required this.content,
    required this.mood,
    this.analysis,
  });

  JournalEntry copyWith({
    String? id,
    DateTime? date,
    String? content,
    String? mood,
    JournalAnalysis? analysis,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      analysis: analysis ?? this.analysis,
    );
  }
}

class JournalAnalysis {
  final int wellnessScore;
  final int stressScore;
  final int focusScore;
  final List<String> triggers;
  final String emotionalSummary;
  final List<String> insights;
  final List<String> recommendations;

  const JournalAnalysis({
    required this.wellnessScore,
    required this.stressScore,
    required this.focusScore,
    required this.triggers,
    required this.emotionalSummary,
    required this.insights,
    required this.recommendations,
  });
}
