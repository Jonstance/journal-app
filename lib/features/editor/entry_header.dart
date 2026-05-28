import 'package:flutter/material.dart';

import '../../core/utils/date_formatters.dart';

class EntryHeader extends StatelessWidget {
  const EntryHeader({
    super.key,
    required this.createdAt,
    required this.weatherSummary,
  });

  final DateTime createdAt;
  final String? weatherSummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = <String>[];
    metadata.add(DateFormatters.time.format(createdAt));
    if (weatherSummary != null) {
      metadata.add(weatherSummary!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormatters.full.format(createdAt),
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          metadata.join(' · '),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
