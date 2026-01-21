import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/journal_entry.dart';
import '../../data/repositories/journal_repository.dart';

final allEntriesProvider = FutureProvider<List<JournalEntry>>((ref) async {
  final repository = ref.read(journalRepositoryProvider);
  return repository.getAllEntries();
});

final entriesOnDateProvider = FutureProvider.family<List<JournalEntry>, DateTime>((ref, date) async {
  final repository = ref.read(journalRepositoryProvider);
  return repository.entriesOnDate(date);
});

final searchEntriesProvider = FutureProvider.family<List<JournalEntry>, String>((ref, query) async {
  final repository = ref.read(journalRepositoryProvider);
  return repository.searchEntries(query);
});
