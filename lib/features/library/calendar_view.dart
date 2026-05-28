import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/utils/date_formatters.dart';
import '../../core/utils/entry_fingerprint.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/models/journal_entry.dart';
import '../reader/reader_screen.dart';
import 'library_providers.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(allEntriesProvider);

    return entriesAsync.when(
      data: (entries) {
        final entryMap = <DateTime, List<JournalEntry>>{};
        for (final entry in entries) {
          final day = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
          entryMap.putIfAbsent(day, () => []).add(entry);
        }

        return Column(
          children: [
            TableCalendar<JournalEntry>(
              firstDay: DateTime.utc(2018, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              headerStyle: HeaderStyle(
                titleTextStyle: theme.textTheme.titleLarge!,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: (day) {
                final target = DateTime(day.year, day.month, day.day);
                return entryMap[target] ?? [];
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _EntryDayList(day: _selectedDay),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Could not load entries: $err')),
    );
  }
}

class _EntryDayList extends ConsumerWidget {
  const _EntryDayList({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesOnDateProvider(day));
    final theme = Theme.of(context);

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Text(
              'No entries on ${DateFormatters.day.format(day)}.',
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        return ListView.separated(
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final fingerprint = EntryFingerprint.fromSeed(entry.id, mood: entry.moodColor);

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ReaderScreen(entry: entry)),
              ),
              child: GlassCard(
                radius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: fingerprint.tintOpacity(),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: fingerprint.toGradient(),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      entry.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Could not load entries: $err')),
    );
  }
}
