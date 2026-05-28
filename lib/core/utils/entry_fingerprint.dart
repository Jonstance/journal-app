import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/colors.dart';

class EntryFingerprint {
  EntryFingerprint(this.primary, this.secondary);

  final Color primary;
  final Color secondary;

  static EntryFingerprint fromSeed(String seed, {Color? mood}) {
    if (mood != null) {
      return EntryFingerprint(mood, mood.withValues(alpha: 0.5));
    }
    final hash = seed.codeUnits.fold<int>(0, (prev, code) => prev + code);
    final palette = AppColors.moodPalette;
    final index = hash % palette.length;
    final next = (index + 3) % palette.length;
    return EntryFingerprint(palette[index], palette[next]);
  }

  LinearGradient toGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primary.withValues(alpha: 0.7), secondary.withValues(alpha: 0.4)],
    );
  }

  double tintOpacity() {
    return 0.18 + Random(primary.toARGB32()).nextDouble() * 0.12;
  }
}
