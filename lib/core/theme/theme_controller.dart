import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeState {
  ThemeState({required this.themeMode, required this.warmthShift});

  final ThemeMode themeMode;
  final double warmthShift;
}

class ThemeController extends StateNotifier<ThemeState> {
  ThemeController() : super(ThemeState(themeMode: ThemeMode.system, warmthShift: _calcWarmth())) {
    _timer = Timer.periodic(const Duration(minutes: 15), (_) => _updateWarmth());
  }

  late final Timer _timer;

  static double _calcWarmth() {
    final now = DateTime.now();
    final hour = now.hour + now.minute / 60.0;
    if (hour < 6) return 0.1;
    if (hour < 12) return 0.35;
    if (hour < 18) return 0.6;
    if (hour < 22) return 0.45;
    return 0.2;
  }

  void setThemeMode(ThemeMode mode) {
    state = ThemeState(themeMode: mode, warmthShift: state.warmthShift);
  }

  void _updateWarmth() {
    state = ThemeState(themeMode: state.themeMode, warmthShift: _calcWarmth());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeState>((ref) {
  return ThemeController();
});
