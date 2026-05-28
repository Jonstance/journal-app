import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/glass_card.dart';
import '../editor/entry_editor_screen.dart';

class _PageData {
  const _PageData({
    required this.icon,
    required this.color,
    required this.headline,
    required this.body,
    required this.features,
  });
  final IconData icon;
  final Color color;
  final String headline;
  final String body;
  final List<String> features;
}

const _featurePages = <_PageData>[
  _PageData(
    icon: Icons.edit_note_outlined,
    color: AppColors.velvetLight,
    headline: 'Write the way you think',
    body: 'Four entry styles adapt to how you feel. Your mood tints the page, voice memos attach inline, and everything saves automatically.',
    features: [
      'Freeform · Bullets · Gratitude · Wins',
      'Mood colour picker',
      'Voice memos & auto-save',
    ],
  ),
  _PageData(
    icon: Icons.bar_chart_rounded,
    color: AppColors.coral,
    headline: 'Reflect on your patterns',
    body: 'A mood timeline, writing heatmap, word cloud, and streak counter surface what matters most over time.',
    features: [
      '30-day mood timeline',
      'Writing frequency heatmap',
      'Streak counter & word cloud',
    ],
  ),
  _PageData(
    icon: Icons.lock_outline_rounded,
    color: Color(0xFF6EA7C8),
    headline: 'Your words stay private',
    body: 'Everything lives on your device by default. AES-256 encrypted backups keep your entries safe — and optional AI prompts help when you\'re stuck.',
    features: [
      'On-device storage by default',
      'Encrypted backup & restore',
      'AI writing prompts (optional)',
    ],
  ),
];

// Total pages = 1 welcome + featurePages
int get _totalPages => 1 + _featurePages.length;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Hive.box('app_prefs').put('hasSeenOnboarding', true);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const EntryEditorScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWelcome = _page == 0;
    final isLast = _page == _totalPages - 1;
    final accent = isWelcome
        ? AppColors.velvet
        : _featurePages[_page - 1].color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar — skip only on feature pages; welcome page has no chrome
            if (!isWelcome)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Skip',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _totalPages,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  if (index == 0) return _WelcomePage(
                    onBeginWriting: _finish,
                    onLearnMore: _next,
                  );
                  return _FeaturePage(data: _featurePages[index - 1]);
                },
              ),
            ),

            // Dots — only on feature pages
            if (!isWelcome) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_featurePages.length, (i) {
                  final active = i == _page - 1;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? accent
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isLast ? 'Begin journaling' : 'Next',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Welcome page (page 0) ───────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onBeginWriting, required this.onLearnMore});
  final VoidCallback onBeginWriting;
  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Small mark — top left
          Image.asset('assets/images/mark.png', width: 28, height: 28)
              .animate()
              .fadeIn(duration: 400.ms),

          const Spacer(),

          // Headline: "Welcome to Velvet."
          RichText(
            text: TextSpan(
              style: theme.textTheme.displaySmall?.copyWith(height: 1.2),
              children: [
                TextSpan(
                  text: 'Welcome to ',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                TextSpan(
                  text: 'Velvet.',
                  style: TextStyle(
                    color: AppColors.velvet,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 500.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),

          const SizedBox(height: 20),

          Text(
            'A quiet place to write. Your entries live on this device — and only here, until you say otherwise.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.6,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),

          const Spacer(),

          // Primary CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBeginWriting,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: AppColors.velvet,
                foregroundColor: AppColors.cream,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BEGIN WRITING',
                    style: AppTheme.brandMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.0,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward, size: 16, color: AppColors.cream),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 320.ms, duration: 500.ms),

          const SizedBox(height: 16),

          // Secondary: swipe to see features
          Center(
            child: TextButton(
              onPressed: onLearnMore,
              style: TextButton.styleFrom(
                foregroundColor:
                    AppColors.velvet.withValues(alpha: 0.6),
              ),
              child: Text(
                'See what\'s inside  →',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.velvet.withValues(alpha: 0.6),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 420.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// ─── Feature pages (pages 1-3) ───────────────────────────────────────────────

class _FeaturePage extends StatelessWidget {
  const _FeaturePage({required this.data});
  final _PageData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, size: 46, color: data.color),
            )
                .animate()
                .scale(
                  begin: const Offset(0.65, 0.65),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 300.ms),
          ),
          const SizedBox(height: 40),
          Text(data.headline, style: theme.textTheme.headlineMedium)
              .animate()
              .fadeIn(delay: 80.ms, duration: 380.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 14),
          Text(
            data.body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              height: 1.55,
            ),
          )
              .animate()
              .fadeIn(delay: 160.ms, duration: 380.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 28),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.features.asMap().entries.map((entry) {
                final isLast = entry.key == data.features.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 17,
                        color: data.color,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
              .animate()
              .fadeIn(delay: 260.ms, duration: 380.ms)
              .slideY(begin: 0.12, end: 0, curve: Curves.easeOut),
        ],
      ),
    );
  }
}
