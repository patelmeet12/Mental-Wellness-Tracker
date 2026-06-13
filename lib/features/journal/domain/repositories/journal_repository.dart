import '../entities/journal_entry.dart';

abstract class JournalRepository {
  Future<List<JournalEntry>> getJournalEntries();
  Future<void> saveJournalEntry(JournalEntry entry);
  Future<void> deleteJournalEntry(String id);
}
