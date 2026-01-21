import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/journal_entry.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/services/weather_service.dart';

class EntryDraftState {
  EntryDraftState({
    required this.type,
    required this.content,
    required this.moodColor,
    required this.createdAt,
    required this.updatedAt,
    required this.isSaving,
    required this.weatherSummary,
    required this.location,
    this.entryId,
  });

  final String? entryId;
  final EntryType type;
  final String content;
  final Color? moodColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSaving;
  final String? weatherSummary;
  final String? location;

  EntryDraftState copyWith({
    String? entryId,
    EntryType? type,
    String? content,
    Color? moodColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSaving,
    String? weatherSummary,
    String? location,
  }) {
    return EntryDraftState(
      entryId: entryId ?? this.entryId,
      type: type ?? this.type,
      content: content ?? this.content,
      moodColor: moodColor ?? this.moodColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSaving: isSaving ?? this.isSaving,
      weatherSummary: weatherSummary ?? this.weatherSummary,
      location: location ?? this.location,
    );
  }
}

class EntryDraftController extends StateNotifier<EntryDraftState> {
  EntryDraftController(this._repository, this._weatherService)
      : super(
          EntryDraftState(
            type: EntryType.freeform,
            content: '',
            moodColor: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isSaving: false,
            weatherSummary: null,
            location: null,
          ),
        ) {
    _hydrateWeather();
  }

  final JournalRepository _repository;
  final WeatherService _weatherService;
  Timer? _debounce;
  Timer? _safetySave;

  void updateContent(String content) {
    state = state.copyWith(content: content, updatedAt: DateTime.now());
    _scheduleSave();
  }

  void updateType(EntryType type) {
    state = state.copyWith(type: type, updatedAt: DateTime.now());
    _scheduleSave();
  }

  void updateMood(Color? color) {
    state = state.copyWith(moodColor: color, updatedAt: DateTime.now());
    _scheduleSave();
  }

  Future<void> completeEntry() async {
    await _saveNow(force: true);
    _resetDraft();
  }

  void _resetDraft() {
    state = EntryDraftState(
      type: EntryType.freeform,
      content: '',
      moodColor: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSaving: false,
      weatherSummary: state.weatherSummary,
      location: state.location,
    );
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () => _saveNow());
    _safetySave ??= Timer.periodic(const Duration(seconds: 8), (_) => _saveNow());
  }

  Future<void> _saveNow({bool force = false}) async {
    if (state.content.trim().isEmpty && !force) return;
    state = state.copyWith(isSaving: true);

    final entry = JournalEntry(
      id: state.entryId,
      type: state.type,
      content: state.content.trimRight(),
      createdAt: state.createdAt,
      updatedAt: DateTime.now(),
      moodColor: state.moodColor,
      weatherSummary: state.weatherSummary,
      location: state.location,
    );

    await _repository.upsertEntry(entry);
    state = state.copyWith(entryId: entry.id, isSaving: false, updatedAt: entry.updatedAt);
  }

  Future<void> _hydrateWeather() async {
    final weather = await _weatherService.fetchCurrentWeather();
    if (weather != null) {
      state = state.copyWith(weatherSummary: '${weather.summary} · ${weather.temperature}');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _safetySave?.cancel();
    super.dispose();
  }
}

final entryDraftControllerProvider = StateNotifierProvider<EntryDraftController, EntryDraftState>((ref) {
  final repository = ref.read(journalRepositoryProvider);
  final weather = ref.read(weatherServiceProvider);
  return EntryDraftController(repository, weather);
});
