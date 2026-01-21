import 'package:flutter/material.dart';

import '../../core/widgets/glass_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      children: [
        Text(
          'Insights',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mood patterns', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              _PlaceholderGraph(label: 'Mood timeline visualization'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Writing frequency', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              _PlaceholderGraph(label: 'Heatmap by week'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Word cloud', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              _PlaceholderGraph(label: 'Favorite words & phrases'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Streak tracking', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Gentle nudges, no pressure.\nYour current streak will appear here once you write regularly.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlaceholderGraph extends StatelessWidget {
  const _PlaceholderGraph({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Center(
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
