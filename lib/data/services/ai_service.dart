import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/journal_entry.dart';

const _apiKeyHiveKey = 'ai_api_key';
const _claudeEndpoint = 'https://api.anthropic.com/v1/messages';
const _model = 'claude-haiku-4-5-20251001';

class AiService {
  static const _prefsBox = 'app_prefs';

  Future<String?> getApiKey() async {
    final box = Hive.box(_prefsBox);
    return box.get(_apiKeyHiveKey) as String?;
  }

  Future<void> saveApiKey(String key) async {
    final box = Hive.box(_prefsBox);
    await box.put(_apiKeyHiveKey, key.trim());
  }

  Future<String?> getWritingPrompt(EntryType type) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) return null;

    final system = switch (type) {
      EntryType.freeform =>
        'You help people journal. Give one warm, open-ended reflective question to help someone start writing freely. One sentence only.',
      EntryType.bullets =>
        'You help people journal. Give one short, specific prompt for bullet-point notes — actionable and direct. One sentence only.',
      EntryType.gratitude =>
        'You help people journal. Give one fresh gratitude prompt that surfaces small, specific joys. Avoid clichés. One sentence only.',
      EntryType.wins =>
        'You help people journal. Give one encouraging prompt to help someone celebrate progress, big or small. One sentence only.',
    };

    return _call(
      apiKey: apiKey,
      system: system,
      user: 'Give me a journaling prompt for today.',
      maxTokens: 80,
    );
  }

  Future<String?> getInsights(List<JournalEntry> entries) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) return null;
    if (entries.isEmpty) return null;

    final snippets = entries.take(14).map((e) {
      final preview = e.content.length > 200
          ? '${e.content.substring(0, 200)}…'
          : e.content;
      final date = e.createdAt.toLocal().toString().substring(0, 10);
      return '[$date, ${e.type.label}]: $preview';
    }).join('\n');

    return _call(
      apiKey: apiKey,
      system:
          'You are a warm journaling companion. Read the user\'s recent journal snippets and write 2–3 sentences reflecting on patterns, themes, or emotional tone you notice. Be specific and personal, not generic. Write naturally, no bullet points.',
      user: 'Here are my recent entries:\n$snippets\n\nWhat patterns or themes do you notice?',
      maxTokens: 200,
    );
  }

  Future<String?> _call({
    required String apiKey,
    required String system,
    required String user,
    int maxTokens = 150,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_claudeEndpoint),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': maxTokens,
          'system': system,
          'messages': [
            {'role': 'user', 'content': user},
          ],
        }),
      );

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['content'] as List?;
      if (content == null || content.isEmpty) return null;
      return (content.first as Map)['text'] as String?;
    } catch (_) {
      return null;
    }
  }
}

final aiServiceProvider = Provider<AiService>((ref) => AiService());
