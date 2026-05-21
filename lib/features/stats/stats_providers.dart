import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/journal_entry.dart';
import '../../data/repositories/local_journal_repository.dart';

class StatsData {
  StatsData({
    required this.entriesByDay,
    required this.currentStreak,
    required this.longestStreak,
    required this.wordFrequencies,
    required this.totalEntries,
    required this.totalWords,
    required this.moodHistory,
  });

  final Map<DateTime, List<JournalEntry>> entriesByDay;
  final int currentStreak;
  final int longestStreak;
  final List<MapEntry<String, int>> wordFrequencies;
  final int totalEntries;
  final int totalWords;
  final List<MapEntry<DateTime, Color?>> moodHistory;
}

const _stopWords = {
  'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
  'of', 'with', 'i', 'is', 'it', 'was', 'be', 'are', 'have', 'had', 'has',
  'my', 'me', 'we', 'he', 'she', 'they', 'this', 'that', 'what', 'so', 'do',
  'did', 'not', 'no', 'as', 'by', 'up', 'if', 'its', 'from', 'all', 'been',
  'just', 'more', 'than', 'into', 'about', 'also', 'can', 'will', 'would',
  'could', 'should', 'get', 'got', 'went', 'go', 'one', 'two', 'his', 'her',
  'their', 'our', 'your', 'you', 'am', 'were', 'there', 'when', 'how', 'out',
  'some', 'then', 'very', 'even', 'still', 'see', 'feel', 'felt', 'like',
  'day', 'time', 'today', 'really', 'much', 'too',
};

StatsData _computeStats(List<JournalEntry> entries) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final byDay = <DateTime, List<JournalEntry>>{};
  for (final e in entries) {
    final day = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
    byDay.putIfAbsent(day, () => []).add(e);
  }

  // Streak: count consecutive days going back from today (or yesterday if none today)
  int currentStreak = 0;
  final startOffset = byDay.containsKey(today)
      ? 0
      : byDay.containsKey(today.subtract(const Duration(days: 1)))
          ? 1
          : -1;
  if (startOffset >= 0) {
    for (int i = startOffset; i < 365; i++) {
      final day = today.subtract(Duration(days: i));
      if (byDay.containsKey(day)) {
        currentStreak++;
      } else {
        break;
      }
    }
  }

  int longestStreak = 0;
  int run = 0;
  for (int i = 0; i < 365; i++) {
    final day = today.subtract(Duration(days: i));
    if (byDay.containsKey(day)) {
      run++;
      if (run > longestStreak) longestStreak = run;
    } else {
      run = 0;
    }
  }

  // Word frequencies
  final wordCounts = <String, int>{};
  int totalWords = 0;
  for (final e in entries) {
    final words = e.content.toLowerCase().split(RegExp(r'[^a-z]+'));
    for (final w in words) {
      if (w.length < 4) continue;
      if (_stopWords.contains(w)) continue;
      wordCounts[w] = (wordCounts[w] ?? 0) + 1;
      totalWords++;
    }
  }
  final sortedWords = wordCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // Mood history: last 30 days, first non-null mood per day (or null)
  final moodHistory = <MapEntry<DateTime, Color?>>[];
  for (int i = 29; i >= 0; i--) {
    final day = today.subtract(Duration(days: i));
    final dayEntries = byDay[day];
    Color? mood;
    if (dayEntries != null) {
      for (final e in dayEntries) {
        if (e.moodColor != null) {
          mood = e.moodColor;
          break;
        }
      }
    }
    moodHistory.add(MapEntry(day, mood));
  }

  return StatsData(
    entriesByDay: byDay,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    wordFrequencies: sortedWords.take(24).toList(),
    totalEntries: entries.length,
    totalWords: totalWords,
    moodHistory: moodHistory,
  );
}

final statsDataProvider = FutureProvider<StatsData>((ref) async {
  final repository = ref.read(journalRepositoryProvider);
  final entries = await repository.getAllEntries();
  return _computeStats(entries);
});
