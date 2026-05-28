import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/splash/splash_screen.dart';

class JournalApp extends ConsumerWidget {
  const JournalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Velvet Journal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(themeState.warmthShift),
      darkTheme: AppTheme.dark(themeState.warmthShift),
      themeMode: themeState.themeMode,
      home: const SplashScreen(),
    );
  }
}
