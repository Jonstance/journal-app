import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/colors.dart';
import '../editor/entry_editor_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final seen = Hive.box('app_prefs')
        .get('hasSeenOnboarding', defaultValue: false) as bool;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            seen ? const EntryEditorScreen() : const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.dusk : AppColors.cream;
    final textColor = isDark ? AppColors.cream : AppColors.ink;
    final subtleColor = isDark
        ? AppColors.cream.withValues(alpha: 0.35)
        : AppColors.inkSoft.withValues(alpha: 0.5);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      isDark ? 'assets/images/mark-cream.png' : 'assets/images/mark.png',
                      width: 80,
                      height: 80,
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 28),
                    Text(
                      'VELVET   JOURNAL',
                      style: AppTheme.brandMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4.5,
                        color: textColor,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Text(
                'PRIVATE  ·  ON DEVICE',
                style: AppTheme.brandMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2.5,
                  color: subtleColor,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
            ),
          ],
        ),
      ),
    );
  }
}
