import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_formatters.dart';
import '../../core/utils/entry_fingerprint.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/voice_memo_player.dart';
import '../../data/models/journal_entry.dart';
import '../../data/models/attachment_ref.dart';
import '../library/library_providers.dart';

class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({super.key, this.entry});

  final JournalEntry? entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entry != null) {
      return _ReaderContent(entry: entry!);
    }

    final entriesAsync = ref.watch(allEntriesProvider);
    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const AppScaffold(
            child: Center(child: Text('No entries yet. Start journaling.')),
          );
        }
        return _ReaderContent(entry: entries.first);
      },
      loading: () => const AppScaffold(child: Center(child: CircularProgressIndicator())),
      error: (err, _) => AppScaffold(child: Center(child: Text('Could not load entry: $err'))),
    );
  }
}

class _ReaderContent extends ConsumerWidget {
  const _ReaderContent({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fingerprint = EntryFingerprint.fromSeed(entry.id, mood: entry.moodColor);

    return AppScaffold(
      appBar: AppBar(
        title: Text('Reader Mode', style: theme.textTheme.titleLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatters.full.format(entry.createdAt),
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  entry.type.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  entry.content,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18, height: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (entry.attachments.any((attachment) => attachment.type == AttachmentType.audio)) ...[
            Text('Voice memo', style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            ...entry.attachments
                .where((attachment) => attachment.type == AttachmentType.audio)
                .map((attachment) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: VoiceMemoPlayer(memo: attachment),
                    )),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              _InsightChip(label: 'On this day', onTap: () => _showOnThisDay(context, ref)),
              const SizedBox(width: 12),
              _InsightChip(label: 'Linked entries', onTap: () {}),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Entry fingerprint', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 12),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: fingerprint.toGradient(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Boosted by ${entry.moodColor != null ? 'your mood' : 'your writing cadence'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
    );
  }

  void _showOnThisDay(BuildContext context, WidgetRef ref) {
    final day = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final entriesAsync = ref.watch(entriesOnDateProvider(day));
        return entriesAsync.when(
          data: (entries) {
            final filtered = entries.where((e) => e.id != entry.id).toList();
            if (filtered.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No other entries on this day yet.'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final past = filtered[index];
                return GlassCard(
                  radius: 18,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    past.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load entries: $err'),
          ),
        );
      },
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Text(label, style: theme.textTheme.labelLarge),
      ),
    );
  }
}
