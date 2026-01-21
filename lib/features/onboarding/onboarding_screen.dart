import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/widgets/app_scaffold.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text('Welcome to Velvet', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 12),
          Text(
            'A journal that feels calm, private, and effortless.\nWrite freely, reflect gently, and let the moments collect.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Begin journaling'),
          ),
          const Spacer(),
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
    );
  }
}
