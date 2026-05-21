import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FocusModeController extends StateNotifier<bool> {
  FocusModeController() : super(_load());

  static const _box = 'app_prefs';
  static const _key = 'focusMode';

  static bool _load() {
    if (!Hive.isBoxOpen(_box)) return false;
    return Hive.box(_box).get(_key, defaultValue: false) as bool;
  }

  void toggle() {
    state = !state;
    Hive.box(_box).put(_key, state);
  }

  void set(bool value) {
    state = value;
    Hive.box(_box).put(_key, value);
  }
}

final focusModeProvider = StateNotifierProvider<FocusModeController, bool>((ref) {
  return FocusModeController();
});
