import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_wellness_tracker/features/journal/domain/entities/journal_entry.dart';
import 'package:mental_wellness_tracker/features/journal/domain/repositories/journal_repository.dart';
import 'package:mental_wellness_tracker/core/services/gemini_service.dart';
import 'package:mental_wellness_tracker/core/providers/core_providers.dart';

final journalProvider = StateNotifierProvider<JournalNotifier, AsyncValue<List<JournalEntry>>>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  final gemini = ref.watch(geminiServiceProvider);
  return JournalNotifier(repo, gemini);
});

class JournalNotifier extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  final JournalRepository _repository;
  final GeminiService _geminiService;

  JournalNotifier(this._repository, this._geminiService) : super(const AsyncValue.loading()) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    try {
      final entries = await _repository.getJournalEntries();
      state = AsyncValue.data(entries);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<JournalEntry?> addEntry({
    required String content,
    required String mood,
    required Map<String, dynamic> studentProfile,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      
      // 1. Analyze with Gemini
      JournalAnalysis? analysis;
      try {
        final analysisJson = await _geminiService.analyzeJournal(content, studentProfile);
        analysis = JournalAnalysis(
          wellnessScore: (analysisJson['wellnessScore'] as num? ?? 70).toInt(),
          stressScore: (analysisJson['stressScore'] as num? ?? 40).toInt(),
          focusScore: (analysisJson['focusScore'] as num? ?? 70).toInt(),
          triggers: (analysisJson['triggers'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
          emotionalSummary: analysisJson['emotionalSummary'] as String? ?? 'Analysis completed.',
          insights: (analysisJson['insights'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
          recommendations: (analysisJson['recommendations'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        );
      } catch (e) {
        // Fallback or rethrow based on key configuration
        rethrow;
      }

      final entry = JournalEntry(
        id: id,
        date: DateTime.now(),
        content: content,
        mood: mood,
        analysis: analysis,
      );

      // 2. Save
      await _repository.saveJournalEntry(entry);
      
      // 3. Reload
      await loadEntries();
      return entry;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _repository.deleteJournalEntry(id);
      await loadEntries();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Calculate streaks dynamically
  Map<String, int> getStreaks() {
    final entries = state.valueOrNull ?? [];
    if (entries.isEmpty) return {'journal': 0, 'mood': 0};

    // Extract sorted dates (newest first)
    final dates = entries.map((e) => DateTime(e.date.year, e.date.month, e.date.day)).toSet().toList();
    dates.sort((a, b) => b.compareTo(a));

    int journalStreak = 0;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    // Check if the most recent entry is today or yesterday
    if (dates.isNotEmpty) {
      final diff = today.difference(dates.first).inDays;
      if (diff <= 1) {
        journalStreak = 1;
        for (int i = 0; i < dates.length - 1; i++) {
          final diffNext = dates[i].difference(dates[i + 1]).inDays;
          if (diffNext == 1) {
            journalStreak++;
          } else if (diffNext > 1) {
            break;
          }
        }
      }
    }

    return {
      'journal': journalStreak,
      'mood': journalStreak,
    };
  }

  // Aggregate average wellness, stress, and focus scores
  Map<String, double> getAverageScores() {
    final entries = state.valueOrNull ?? [];
    final analyzed = entries.where((e) => e.analysis != null).toList();
    if (analyzed.isEmpty) {
      return {'wellness': 75.0, 'stress': 35.0, 'focus': 80.0};
    }

    double totalWellness = 0;
    double totalStress = 0;
    double totalFocus = 0;

    for (final e in analyzed) {
      totalWellness += e.analysis!.wellnessScore;
      totalStress += e.analysis!.stressScore;
      totalFocus += e.analysis!.focusScore;
    }

    final count = analyzed.length;
    return {
      'wellness': totalWellness / count,
      'stress': totalStress / count,
      'focus': totalFocus / count,
    };
  }
}
