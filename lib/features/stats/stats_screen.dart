import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/colors.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/models/journal_entry.dart';
import '../ai/ai_providers.dart';
import 'stats_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsDataProvider);
    final theme = Theme.of(context);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Could not load stats: $err')),
      data: (stats) {
        if (stats.totalEntries == 0) {
          return Center(
            child: Text(
              'Your insights will appear here\nonce you have written a few entries.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Text('Insights', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            _SummaryRow(stats: stats),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mood', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Last 30 days', style: theme.textTheme.labelSmall),
                  const SizedBox(height: 16),
                  _MoodTimeline(moodHistory: stats.moodHistory),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Writing frequency', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Last 12 weeks', style: theme.textTheme.labelSmall),
                  const SizedBox(height: 16),
                  _FrequencyHeatmap(entriesByDay: stats.entriesByDay),
                ],
              ),
            ),
            if (stats.wordFrequencies.isNotEmpty) ...[
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your words', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.totalWords} total words written',
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 16),
                    _WordCloud(words: stats.wordFrequencies),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            GlassCard(
              child: _StreakCard(
                current: stats.currentStreak,
                longest: stats.longestStreak,
              ),
            ),
            const SizedBox(height: 16),
            const _AiInsightsCard(),
          ],
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.stats});

  final StatsData stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatChip(label: 'Entries', value: '${stats.totalEntries}')),
        const SizedBox(width: 12),
        Expanded(child: _StatChip(label: 'Streak', value: '${stats.currentStreak}d')),
        const SizedBox(width: 12),
        Expanded(child: _StatChip(label: 'Best', value: '${stats.longestStreak}d')),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          Text(value, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _MoodTimeline extends StatelessWidget {
  const _MoodTimeline({required this.moodHistory});

  final List<MapEntry<DateTime, Color?>> moodHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emptyColor = theme.colorScheme.onSurface.withValues(alpha: 0.08);
    final hasAnyMood = moodHistory.any((e) => e.value != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: moodHistory.map((entry) {
            final color = entry.value ?? emptyColor;
            return Expanded(
              child: Tooltip(
                message: DateFormatters.short.format(entry.key),
                child: Container(
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (!hasAnyMood) ...[
          const SizedBox(height: 10),
          Text(
            'Set a mood when writing to see your patterns here.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _FrequencyHeatmap extends StatelessWidget {
  const _FrequencyHeatmap({required this.entriesByDay});

  final Map<DateTime, List<JournalEntry>> entriesByDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final accent = theme.colorScheme.secondary;
    final emptyColor = theme.colorScheme.onSurface.withValues(alpha: 0.07);

    // 12 columns of 7 days = 84 days, ending on today's weekday
    final daysBack = today.weekday % 7; // days since last Sunday
    final gridStart = today.subtract(Duration(days: 83 + daysBack));

    final allDays = List.generate(84 + daysBack, (i) => gridStart.add(Duration(days: i)));
    final trimmed = allDays.length > 84 ? allDays.sublist(allDays.length - 84) : allDays;

    final weeks = <List<DateTime>>[];
    for (int i = 0; i < trimmed.length; i += 7) {
      weeks.add(trimmed.sublist(i, i + 7));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: weeks.map((week) {
            return Expanded(
              child: Column(
                children: week.map((day) {
                  final count = entriesByDay[day]?.length ?? 0;
                  final isFuture = day.isAfter(today);
                  final Color cellColor;
                  if (isFuture || count == 0) {
                    cellColor = emptyColor;
                  } else if (count == 1) {
                    cellColor = accent.withValues(alpha: 0.4);
                  } else if (count == 2) {
                    cellColor = accent.withValues(alpha: 0.65);
                  } else {
                    cellColor = accent;
                  }

                  return Tooltip(
                    message: '${DateFormatters.short.format(day)}: $count entr${count == 1 ? 'y' : 'ies'}',
                    child: Container(
                      margin: const EdgeInsets.all(1.5),
                      height: 12,
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Less', style: theme.textTheme.labelSmall),
            const SizedBox(width: 4),
            ...List.generate(4, (i) {
              final alphas = [0.07, 0.4, 0.65, 1.0];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: i == 0
                      ? emptyColor
                      : accent.withValues(alpha: alphas[i]),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
            const SizedBox(width: 4),
            Text('More', style: theme.textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}

class _WordCloud extends StatelessWidget {
  const _WordCloud({required this.words});

  final List<MapEntry<String, int>> words;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppColors.moodPalette;
    final maxCount = words.isEmpty ? 1 : words.first.value;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: words.asMap().entries.map((entry) {
        final index = entry.key;
        final word = entry.value.key;
        final count = entry.value.value;
        final ratio = count / maxCount;
        final fontSize = 11.0 + ratio * 14.0;
        final color = palette[index % palette.length];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            word,
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: fontSize,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AiInsightsCard extends ConsumerStatefulWidget {
  const _AiInsightsCard();

  @override
  ConsumerState<_AiInsightsCard> createState() => _AiInsightsCardState();
}

class _AiInsightsCardState extends ConsumerState<_AiInsightsCard> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, size: 18, color: accent),
              const SizedBox(width: 8),
              Text('AI Reflection', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 8),
          if (!_requested) ...[
            Text(
              'Get a personalised reflection on your recent entries — patterns, themes, and emotional tone.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => setState(() => _requested = true),
              icon: const Icon(Icons.auto_awesome_outlined, size: 16),
              label: const Text('Reflect on my entries'),
            ),
          ] else ...[
            Consumer(
              builder: (context, ref, _) {
                final insightsAsync = ref.watch(aiInsightsProvider);
                return insightsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Reflecting…'),
                      ],
                    ),
                  ),
                  error: (_, __) => Text(
                    'Could not load insights. Check your API key in Settings.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  data: (insight) {
                    if (insight == null) {
                      return Text(
                        'Add your Claude API key in Settings to enable AI reflections.',
                        style: theme.textTheme.bodyMedium,
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(insight, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ref.invalidate(aiInsightsProvider);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: accent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Refresh'),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.current, required this.longest});

  final int current;
  final int longest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Streak', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.local_fire_department_outlined, color: accent, size: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current == 0
                      ? 'No active streak'
                      : '$current day${current == 1 ? '' : 's'} in a row',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  'Best: $longest day${longest == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          current == 0
              ? 'Write today to start a new streak.'
              : 'Keep it going — write again tomorrow.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
