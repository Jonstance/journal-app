# Velvet Journal

A calm, privacy-first journaling app built with Flutter. Entries live on-device by default; optional encrypted sync is planned.

---

## Features

### Writing
- **4 entry types** — Freeform, Bullet Notes, Gratitude, Wins — each with its own auto-bullet behaviour and hint text
- **Mood picker** — a colour swatch that tints the editor background and is recorded per entry
- **Markdown-lite toolbar** — bold, italic, and blockquote shortcuts
- **Voice memos** — attach and play back audio recordings inline
- **Auto-save** — debounced 2-second save with an 8-second safety timer; no manual save needed

### Library
- **Timeline** — all entries in reverse-chronological order, each card tinted by mood or a deterministic fingerprint colour
- **Calendar** — `table_calendar` view; tap a day to see its entries
- **Full-text search** — queries the Hive box directly, results sorted newest-first

### Insights
- **Mood strip** — 30-day colour timeline showing the mood set on each day's entry
- **Frequency heatmap** — GitHub-style 12-week grid; cell opacity scales with entry count
- **Word cloud** — top 24 most-used words (stopwords excluded), chip size proportional to frequency
- **Streak counter** — current consecutive-day streak and all-time best, with a one-day grace period

### Settings
- **Theme** — Light / Dark / System, with an automatic warmth shift that adjusts colour temperature by time of day
- **Focus mode** — toggle that hides the navigation icon row in the editor for distraction-free writing; persists across restarts
- **Encrypted backups** — export/import a `.journal` file; AES-256-GCM with PBKDF2-SHA256 (120 000 iterations) key derivation; password strength meter enforces a minimum before allowing export
- **Encrypted sync** — planned; a bottom sheet explains what it will do when the button is tapped

---

## Architecture

```
lib/
├── app.dart                      # MaterialApp root, theme wiring
├── main.dart                     # Hive init, ProviderScope
├── core/
│   ├── theme/
│   │   ├── app_theme.dart        # Light/dark ThemeData, Google Fonts (Lora + Sora)
│   │   ├── colors.dart           # AppColors palette + moodPalette list
│   │   └── theme_controller.dart # StateNotifier; warmth shift timer
│   ├── utils/
│   │   ├── backup_codec.dart     # PBKDF2 + AES-GCM encrypt/decrypt
│   │   ├── date_formatters.dart  # Shared intl DateFormat instances
│   │   └── entry_fingerprint.dart# Deterministic gradient from entry ID
│   └── widgets/
│       ├── app_scaffold.dart
│       ├── glass_card.dart
│       ├── pill_button.dart
│       └── voice_memo_player.dart
├── data/
│   ├── models/
│   │   ├── attachment_ref.dart   # AttachmentRef + AttachmentType enum
│   │   └── journal_entry.dart    # JournalEntry model + EntryType enum
│   ├── repositories/
│   │   ├── journal_repository.dart        # Abstract interface
│   │   └── local_journal_repository.dart  # Hive implementation
│   └── services/
│       ├── attachments_service.dart # Audio recording; file-based refs
│       ├── export_service.dart      # Encrypted backup export/import
│       ├── sync_service.dart        # Stub (sync not yet implemented)
│       └── weather_service.dart     # Stub (returns null)
└── features/
    ├── editor/
    │   ├── entry_draft_controller.dart  # StateNotifier; auto-save, weather hydration
    │   ├── entry_editor_screen.dart     # Main writing screen
    │   ├── entry_header.dart            # Date + weather line
    │   ├── mood_picker.dart             # Horizontal colour swatches
    │   └── type_switcher.dart           # Segmented entry-type selector
    ├── library/
    │   ├── calendar_view.dart
    │   ├── library_providers.dart       # allEntries / entriesOnDate / search providers
    │   ├── library_screen.dart          # TabBar: Timeline | Calendar | Insights
    │   ├── search_screen.dart
    │   └── timeline_view.dart
    ├── onboarding/
    │   └── onboarding_screen.dart
    ├── reader/
    │   └── reader_screen.dart
    ├── settings/
    │   ├── focus_mode_controller.dart   # StateNotifier; persisted in app_prefs Hive box
    │   └── settings_screen.dart
    └── stats/
        ├── stats_providers.dart         # FutureProvider; streak / word freq / mood history
        └── stats_screen.dart            # Mood strip, heatmap, word cloud, streak card
```

**State management:** Riverpod (`StateNotifierProvider`, `FutureProvider`, `FutureProvider.family`)

**Storage:** Hive — two boxes:
- `journal_entries` — `Map` values serialised by `JournalEntry.toMap()`
- `app_prefs` — loose key/value store (currently holds `focusMode: bool`)

**Navigation:** `Navigator.push` with `PageRouteBuilder` fade transitions; no named routes or go_router.

---

## Getting started

```bash
flutter pub get
flutter run
```

Requires Flutter 3.x with Dart SDK `>=3.2.0`. No backend or API keys needed — everything runs locally.

### iOS audio permissions

Voice memo recording requires microphone permission. Add to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Velvet uses the microphone to record voice memos attached to journal entries.</string>
```

---

## Extending the app

### Implementing real weather
Replace `StubWeatherService` in `lib/data/services/weather_service.dart` with a concrete implementation and register it in `weatherServiceProvider`.

### Implementing encrypted sync
Implement `SyncService` in `lib/data/services/sync_service.dart` and swap the provider in `syncServiceProvider`. The UI in Settings is already wired — the "coming soon" bottom sheet will need to be replaced with actual enable/disable logic.

### Adding a new entry type
1. Add a value to `EntryType` in `lib/data/models/journal_entry.dart`
2. Add `label`, `description`, hint text (`_hintForType`), and bullet prefix (`_bulletPrefixForType`) in the editor
3. The type is serialised by name, so existing entries are unaffected

---

## Key dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `hive` / `hive_flutter` | Local persistence |
| `cryptography` | AES-GCM backup encryption + PBKDF2 |
| `just_audio` | Voice memo playback |
| `table_calendar` | Calendar view |
| `google_fonts` | Lora (body) + Sora (UI) typefaces |
| `flutter_animate` | Entry animations |
| `file_picker` | Backup file save/open dialogs |
| `path_provider` | File system paths |
| `intl` | Date formatting |
