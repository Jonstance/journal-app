import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pill_button.dart';
import '../../core/widgets/voice_memo_player.dart';
import '../../data/models/attachment_ref.dart';
import '../../data/models/journal_entry.dart';
import '../../data/services/attachments_service.dart';
import '../../data/services/ai_service.dart';
import '../ai/ai_providers.dart';
import '../library/library_screen.dart';
import '../library/search_screen.dart';
import '../reader/reader_screen.dart';
import '../settings/focus_mode_controller.dart';
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
  String? _promptText;
  bool _isLoadingPrompt = false;

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
      case EntryType.gratitude:
      case EntryType.wins:
        return '• ';
      case EntryType.freeform:
        return '';
    }
  }

  Future<void> _fetchPrompt() async {
    final type = ref.read(entryDraftControllerProvider).type;
    final apiKey = await ref.read(aiServiceProvider).getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add your Claude API key in Settings to use AI prompts.'),
        ),
      );
      return;
    }
    setState(() {
      _isLoadingPrompt = true;
      _promptText = null;
    });
    final prompt = await ref.read(writingPromptProvider(type).future);
    if (!mounted) return;
    setState(() {
      _promptText = prompt;
      _isLoadingPrompt = false;
    });
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
    final focusMode = ref.watch(focusModeProvider);

    return AppScaffold(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BrandHeader(),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: EntryHeader(
                      createdAt: state.createdAt,
                      weatherSummary: state.weatherSummary,
                    ),
                  ),
                  if (focusMode)
                    IconButton(
                      tooltip: 'Exit focus mode',
                      onPressed: () => ref.read(focusModeProvider.notifier).toggle(),
                      icon: const Icon(Icons.fullscreen_exit_outlined),
                    )
                  else ...[
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const ReaderScreen(),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                        ),
                      ),
                      icon: const Icon(Icons.chrome_reader_mode_outlined),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const SearchScreen(),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                        ),
                      ),
                      icon: const Icon(Icons.search),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const LibraryScreen(),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                        ),
                      ),
                      icon: const Icon(Icons.calendar_month_outlined),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const SettingsScreen(),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                        ),
                      ),
                      icon: const Icon(Icons.tune),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: Text(
                  state.type.description,
                  key: ValueKey(state.type),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TypeSwitcher(
                value: state.type,
                onChanged: (type) =>
                    ref.read(entryDraftControllerProvider.notifier).updateType(type),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Mood',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: MoodPicker(
                        value: state.moodColor,
                        onChanged: (color) =>
                            ref.read(entryDraftControllerProvider.notifier).updateMood(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      state.isSaving ? 'Saving…' : 'All changes saved',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
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
                                    state.moodColor!.withValues(alpha: 0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      Column(
                        children: [
                          _MarkdownToolbar(
                            onBold: () => _wrapSelection('**'),
                            onItalic: () => _wrapSelection('*'),
                            onQuote: _toggleQuoteForSelection,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: _hintForType(state.type),
                                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoadingPrompt || _promptText != null) ...[
                const SizedBox(height: 12),
                _PromptCard(
                  text: _promptText,
                  isLoading: _isLoadingPrompt,
                  onUse: () {
                    final current = _controller.text;
                    final insert = _promptText ?? '';
                    _controller.text =
                        current.isEmpty ? insert : '$insert\n\n$current';
                    _controller.selection = TextSelection.collapsed(
                      offset: _controller.text.length,
                    );
                    setState(() => _promptText = null);
                  },
                  onDismiss: () => setState(() => _promptText = null),
                ),
              ],
              if (state.attachments.isNotEmpty) ...[
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice memo',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...state.attachments
                        .where((a) => a.type == AttachmentType.audio)
                        .map((a) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: VoiceMemoPlayer(memo: a),
                            )),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _recordVoiceMemo(ref),
                    icon: const Icon(Icons.mic_none),
                    label: const Text('Add voice memo'),
                  ),
                  const Spacer(),
                  Text(
                    state.isSaving ? 'Saving…' : 'All changes saved',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  PillButton(
                    label: _isLoadingPrompt ? 'Thinking…' : 'Spark',
                    icon: Icons.auto_awesome_outlined,
                    onPressed: _isLoadingPrompt ? () {} : _fetchPrompt,
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
                      color: theme.colorScheme.secondary.withValues(alpha: 0.18),
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

  Future<void> _recordVoiceMemo(WidgetRef ref) async {
    HapticFeedback.selectionClick();
    final service = ref.read(attachmentsServiceProvider);
    final memo = await service.recordAudio();
    if (memo != null) {
      ref.read(entryDraftControllerProvider.notifier).addAttachment(memo);
    }
  }

  void _wrapSelection(String wrapper) {
    final selection = _controller.selection;
    final text = _controller.text;
    if (!selection.isValid) return;

    final start = selection.start;
    final end = selection.end;
    if (start == end) {
      final insert = '$wrapper$wrapper';
      _controller.text = text.replaceRange(start, end, insert);
      _controller.selection = TextSelection.collapsed(offset: start + wrapper.length);
      return;
    }

    final selected = text.substring(start, end);
    final wrapped = '$wrapper$selected$wrapper';
    _controller.text = text.replaceRange(start, end, wrapped);
    _controller.selection =
        TextSelection(baseOffset: start, extentOffset: start + wrapped.length);
  }

  void _toggleQuoteForSelection() {
    final selection = _controller.selection;
    final text = _controller.text;
    if (!selection.isValid) return;

    final start = selection.start;
    final end = selection.end;
    final lineStart = text.lastIndexOf('\n', start - 1) + 1;
    final lineEnd = text.indexOf('\n', end);
    final effectiveEnd = lineEnd == -1 ? text.length : lineEnd;
    final line = text.substring(lineStart, effectiveEnd);

    final trimmed = line.trimLeft();
    final hasQuote = trimmed.startsWith('> ');
    final updatedLine =
        hasQuote ? line.replaceFirst(RegExp(r'\s*> '), '') : '> $line';

    _controller.text = text.replaceRange(lineStart, effectiveEnd, updatedLine);
    final delta = updatedLine.length - line.length;
    _controller.selection = TextSelection(
      baseOffset: (start + delta).clamp(0, _controller.text.length),
      extentOffset: (end + delta).clamp(0, _controller.text.length),
    );
  }
}

class _MarkdownToolbar extends StatelessWidget {
  const _MarkdownToolbar({
    required this.onBold,
    required this.onItalic,
    required this.onQuote,
  });

  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onQuote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _ToolbarButton(
          label: 'B',
          onTap: onBold,
          textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
        _ToolbarButton(
          label: 'I',
          onTap: onItalic,
          textStyle: theme.textTheme.labelLarge?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(width: 8),
        _ToolbarButton(
          label: 'Quote',
          onTap: onQuote,
          textStyle: theme.textTheme.labelLarge,
        ),
        const Spacer(),
        Text(
          'Markdown-lite',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.label, required this.onTap, this.textStyle});

  final String label;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Text(label, style: textStyle ?? theme.textTheme.labelLarge),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              isDark ? 'assets/images/mark-cream.png' : 'assets/images/mark.png',
              width: 18,
              height: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'VELVET   JOURNAL',
              style: AppTheme.brandMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
                const SizedBox(width: 4),
                Text(
                  'ON DEVICE',
                  style: AppTheme.brandMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.0,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          height: 1,
          thickness: 0.5,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.text,
    required this.isLoading,
    required this.onUse,
    required this.onDismiss,
  });

  final String? text;
  final bool isLoading;
  final VoidCallback onUse;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: isLoading
          ? Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Getting a prompt…', style: theme.textTheme.bodyMedium),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_outlined, size: 14, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      'Prompt',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: accent),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onDismiss,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(text ?? '', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onUse,
                    style: TextButton.styleFrom(
                      foregroundColor: accent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Use this prompt'),
                  ),
                ),
              ],
            ),
    );
  }
}
