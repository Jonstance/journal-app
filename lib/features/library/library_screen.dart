import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/widgets/app_scaffold.dart';
import '../stats/stats_screen.dart';
import 'calendar_view.dart';
import 'timeline_view.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: AppScaffold(
        appBar: AppBar(
          title: Text('Your Library', style: theme.textTheme.titleLarge),
          centerTitle: false,
          bottom: TabBar(
            indicatorColor: theme.colorScheme.secondary,
            labelColor: theme.colorScheme.onSurface,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            tabs: const [
              Tab(text: 'Timeline'),
              Tab(text: 'Calendar'),
              Tab(text: 'Insights'),
            ],
          ),
        ),
        child: const TabBarView(
          children: [
            TimelineView(),
            CalendarView(),
            StatsScreen(),
          ],
        ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }
}
