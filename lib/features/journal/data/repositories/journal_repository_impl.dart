import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../models/journal_entry_model.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/errors/failures.dart';

class JournalRepositoryImpl implements JournalRepository {
  final StorageService _storageService;

  JournalRepositoryImpl(this._storageService);

  @override
  Future<List<JournalEntry>> getJournalEntries() async {
    try {
      final list = _storageService.getJournals();
      return list.map((e) => JournalEntryModel.fromJson(e)).toList();
    } catch (e) {
      throw CacheFailure('Failed to load journal entries: $e');
    }
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    try {
      final entries = await getJournalEntries();
      final model = JournalEntryModel.fromEntity(entry);

      // Check if entry already exists (edit) or is new
      final index = entries.indexWhere((element) => element.id == entry.id);
      
      final updatedList = entries.map((e) => JournalEntryModel.fromEntity(e).toJson()).toList();
      
      if (index != -1) {
        updatedList[index] = model.toJson();
      } else {
        updatedList.insert(0, model.toJson()); // Insert newest first
      }

      await _storageService.saveJournals(updatedList);
    } catch (e) {
      throw CacheFailure('Failed to save journal entry: $e');
    }
  }

  @override
  Future<void> deleteJournalEntry(String id) async {
    try {
      final entries = await getJournalEntries();
      entries.removeWhere((element) => element.id == id);
      
      final listToSave = entries.map((e) => JournalEntryModel.fromEntity(e).toJson()).toList();
      await _storageService.saveJournals(listToSave);
    } catch (e) {
      throw CacheFailure('Failed to delete journal entry: $e');
    }
  }
}
