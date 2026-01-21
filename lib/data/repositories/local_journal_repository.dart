import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/journal_entry.dart';
import 'journal_repository.dart';

class LocalJournalRepository implements JournalRepository {
  static const _boxName = 'journal_entries';

  static Future<void> ensureInitialized() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Map>(_boxName);
    }
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  @override
  Future<void> upsertEntry(JournalEntry entry) async {
    await _box.put(entry.id, entry.toMap());
  }

  @override
  Future<JournalEntry?> getEntry(String id) async {
    final data = _box.get(id);
    if (data == null) return null;
    return JournalEntry.fromMap(data);
  }

  @override
  Future<List<JournalEntry>> getAllEntries() async {
    final entries = _box.values
        .map((data) => JournalEntry.fromMap(data))
        .toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<JournalEntry>> searchEntries(String query) async {
    final lower = query.toLowerCase();
    final entries = _box.values
        .map((data) => JournalEntry.fromMap(data))
        .where((entry) => entry.content.toLowerCase().contains(lower))
        .toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  @override
  Future<List<JournalEntry>> entriesOnDate(DateTime date) async {
    final target = DateTime(date.year, date.month, date.day);
    final next = target.add(const Duration(days: 1));
    final entries = _box.values
        .map((data) => JournalEntry.fromMap(data))
        .where((entry) => entry.createdAt.isAfter(target) && entry.createdAt.isBefore(next))
        .toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  @override
  Future<void> replaceAllEntries(List<JournalEntry> entries) async {
    await _box.clear();
    final Map<String, Map<String, dynamic>> payload = {
      for (final entry in entries) entry.id: entry.toMap(),
    };
    await _box.putAll(payload);
  }
}

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return LocalJournalRepository();
});
