import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/journal_entry.dart';
import '../../data/repositories/local_journal_repository.dart';
import '../../data/services/ai_service.dart';

final writingPromptProvider =
    FutureProvider.autoDispose.family<String?, EntryType>((ref, type) {
  final service = ref.read(aiServiceProvider);
  return service.getWritingPrompt(type);
});

final aiInsightsProvider = FutureProvider.autoDispose<String?>((ref) async {
  final service = ref.read(aiServiceProvider);
  final repo = ref.read(journalRepositoryProvider);
  final entries = await repo.getAllEntries();
  return service.getInsights(entries);
});
