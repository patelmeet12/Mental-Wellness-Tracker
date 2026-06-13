import '../../domain/entities/journal_entry.dart';

class JournalEntryModel extends JournalEntry {
  const JournalEntryModel({
    required super.id,
    required super.date,
    required super.content,
    required super.mood,
    super.analysis,
  });

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String? ?? '',
      date: DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
      content: json['content'] as String? ?? '',
      mood: json['mood'] as String? ?? 'Neutral',
      analysis: json['analysis'] != null
          ? JournalAnalysisModel.fromJson(json['analysis'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'content': content,
      'mood': mood,
      'analysis': analysis != null
          ? (analysis as JournalAnalysisModel).toJson()
          : null,
    };
  }

  factory JournalEntryModel.fromEntity(JournalEntry entity) {
    return JournalEntryModel(
      id: entity.id,
      date: entity.date,
      content: entity.content,
      mood: entity.mood,
      analysis: entity.analysis,
    );
  }
}

class JournalAnalysisModel extends JournalAnalysis {
  const JournalAnalysisModel({
    required super.wellnessScore,
    required super.stressScore,
    required super.focusScore,
    required super.triggers,
    required super.emotionalSummary,
    required super.insights,
    required super.recommendations,
  });

  factory JournalAnalysisModel.fromJson(Map<String, dynamic> json) {
    return JournalAnalysisModel(
      wellnessScore: (json['wellnessScore'] as num? ?? 70).toInt(),
      stressScore: (json['stressScore'] as num? ?? 40).toInt(),
      focusScore: (json['focusScore'] as num? ?? 70).toInt(),
      triggers: (json['triggers'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      emotionalSummary: json['emotionalSummary'] as String? ?? '',
      insights: (json['insights'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      recommendations: (json['recommendations'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wellnessScore': wellnessScore,
      'stressScore': stressScore,
      'focusScore': focusScore,
      'triggers': triggers,
      'emotionalSummary': emotionalSummary,
      'insights': insights,
      'recommendations': recommendations,
    };
  }
}
