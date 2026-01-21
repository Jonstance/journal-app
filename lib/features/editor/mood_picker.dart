import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/colors.dart';

class MoodPicker extends StatelessWidget {
  const MoodPicker({super.key, required this.value, required this.onChanged});

  final Color? value;
  final ValueChanged<Color?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...AppColors.moodPalette.map(
          (color) => GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(color == value ? null : color);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(right: 10),
              width: value == color ? 28 : 22,
              height: value == color ? 28 : 22,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: value == color
                    ? Border.all(color: Colors.white.withOpacity(0.9), width: 2)
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
