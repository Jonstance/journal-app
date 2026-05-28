import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/journal_entry.dart';

class TypeSwitcher extends StatelessWidget {
  const TypeSwitcher({super.key, required this.value, required this.onChanged});

  final EntryType value;
  final ValueChanged<EntryType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Wrap(
        spacing: 6,
        children: EntryType.values
            .map(
              (type) => GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: value == type
                        ? theme.colorScheme.secondary.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    type.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: value == type
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
