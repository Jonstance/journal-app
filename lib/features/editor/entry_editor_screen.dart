import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_formatters.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pill_button.dart';
import '../../data/models/journal_entry.dart';
import '../library/library_screen.dart';
import '../library/search_screen.dart';
import '../reader/reader_screen.dart';
import '../settings/settings_screen.dart';
import 'entry_draft_controller.dart';
import 'entry_header.dart';
import 'mood_picker.dart';
import 'type_switcher.dart';

class EntryEditorScreen extends ConsumerStatefulWidget {
  const EntryEditorScreen({super.key});

  @override
  ConsumerState<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends ConsumerState<EntryEditorScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFormatting = false;
  bool _showCompletion = false;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(entryDraftControllerProvider);
    _controller = TextEditingController(text: initial.content);
    _focusNode = FocusNode();
    _controller.addListener(_handleTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    if (_isFormatting) return;
    final notifier = ref.read(entryDraftControllerProvider.notifier);
    final type = ref.read(entryDraftControllerProvider).type;
    final text = _controller.text;

    if (_shouldAutoBullet(type) && text.endsWith('\n')) {
      _isFormatting = true;
      final prefix = _bulletPrefixForType(type);
      _controller.text = '$text$prefix';
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
      _isFormatting = false;
    }

    notifier.updateContent(_controller.text);
  }

  bool _shouldAutoBullet(EntryType type) {
    return type == EntryType.bullets || type == EntryType.gratitude || type == EntryType.wins;
  }

  String _bulletPrefixForType(EntryType type) {
    switch (type) {
      case EntryType.bullets:
        return '• ';
      case EntryType.gratitude:
        return '• ';
      case EntryType.wins:
        return '• ';
      case EntryType.freeform:
        return '';
    }
  }

  Future<void> _completeEntry() async {
    HapticFeedback.mediumImpact();
    await ref.read(entryDraftControllerProvider.notifier).completeEntry();
    _controller.clear();
    _focusNode.requestFocus();
    setState(() => _showCompletion = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _showCompletion = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EntryDraftState>(entryDraftControllerProvider, (previous, next) {
      if (previous == null) return;
      if (previous.content.isNotEmpty && next.content.isEmpty) {
        _controller.text = '';
      }
    });

    final theme = Theme.of(context);
    final state = ref.watch(entryDraftControllerProvider);

    return AppScaffold(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: EntryHeader(
                      createdAt: state.createdAt,
                      weatherSummary: state.weatherSummary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const ReaderScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.chrome_reader_mode_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const SearchScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const LibraryScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const SettingsScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: Text(
                  state.type.description,
                  key: ValueKey(state.type),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TypeSwitcher(
                value: state.type,
                onChanged: (type) => ref.read(entryDraftControllerProvider.notifier).updateType(type),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Mood',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  MoodPicker(
                    value: state.moodColor,
                    onChanged: (color) => ref.read(entryDraftControllerProvider.notifier).updateMood(color),
                  ),
                  const Spacer(),
                  Text(
                    state.isSaving ? 'Saving…' : 'All changes saved',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Stack(
                    children: [
                      if (state.moodColor != null)
                        Positioned.fill(
                          child: Opacity(
                            opacity: theme.brightness == Brightness.dark ? 0.12 : 0.18,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    state.moodColor!.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: _hintForType(state.type),
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.35),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  PillButton(
                    label: 'Today · ${DateFormatters.short.format(DateTime.now())}',
                    icon: Icons.auto_awesome_outlined,
                    onPressed: () {},
                  ),
                  const Spacer(),
                  PillButton(
                    label: 'Finish Entry',
                    icon: Icons.check_circle_outline,
                    isActive: true,
                    onPressed: _completeEntry,
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04, end: 0),
          if (_showCompletion)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 48,
                      color: theme.colorScheme.secondary,
                    ),
                  )
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.easeOutBack)
                      .fadeOut(delay: 700.ms),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _hintForType(EntryType type) {
    switch (type) {
      case EntryType.freeform:
        return 'Start writing. The page is yours.';
      case EntryType.bullets:
        return '• Focus highlights\n• Ideas to explore\n• Notes to revisit';
      case EntryType.gratitude:
        return '• A moment I appreciated\n• Someone who helped me\n• A small win';
      case EntryType.wins:
        return '• Something I finished\n• A risk I took\n• A step forward';
    }
  }
}
