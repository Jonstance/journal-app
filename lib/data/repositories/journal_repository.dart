import '../models/journal_entry.dart';

abstract class JournalRepository {
  Future<void> upsertEntry(JournalEntry entry);
  Future<JournalEntry?> getEntry(String id);
  Future<List<JournalEntry>> getAllEntries();
  Future<void> deleteEntry(String id);
  Future<List<JournalEntry>> searchEntries(String query);
  Future<List<JournalEntry>> entriesOnDate(DateTime date);
  Future<void> replaceAllEntries(List<JournalEntry> entries);
}
