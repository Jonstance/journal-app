import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/services/ai_service.dart';
import '../../data/services/export_service.dart';
import 'focus_mode_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeControllerProvider);

    return AppScaffold(
      appBar: AppBar(title: Text('Settings', style: theme.textTheme.titleLarge)),
      child: ListView(
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                _ThemeOption(
                  label: 'System',
                  selected: themeState.themeMode == ThemeMode.system,
                  onTap: () => ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.system),
                ),
                _ThemeOption(
                  label: 'Light',
                  selected: themeState.themeMode == ThemeMode.light,
                  onTap: () => ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.light),
                ),
                _ThemeOption(
                  label: 'Dark',
                  selected: themeState.themeMode == ThemeMode.dark,
                  onTap: () => ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privacy', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Your journal lives on-device. Sync is optional and will be end-to-end encrypted.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _showSyncComingSoon(context),
                  child: const Text('Enable encrypted sync'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Focus mode', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Hide navigation buttons while writing for a distraction-free experience.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, _) {
                    final focusMode = ref.watch(focusModeProvider);
                    return SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Distraction-free writing',
                        style: theme.textTheme.bodyLarge,
                      ),
                      value: focusMode,
                      onChanged: (_) => ref.read(focusModeProvider.notifier).toggle(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _AiSettingsCard(),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Backups', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Create a single encrypted .journal file to store in Files, Google Drive, or iCloud.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _exportBackup(context, ref),
                        child: const Text('Export backup'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _importBackup(context, ref),
                        child: const Text('Import backup'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSyncComingSoon(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Encrypted sync', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                'Cross-device sync is coming in a future update. When enabled, your entries will be encrypted on-device before leaving — only you will hold the key.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Until then, use the backup feature below to move your journal between devices.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final passphrase = await _askPassphrase(context, title: 'Create backup password');
    if (passphrase == null || passphrase.trim().isEmpty) return;

    final exportService = ref.read(exportServiceProvider);
    final file = await exportService.exportEncryptedBackup(passphrase: passphrase.trim());
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(file == null ? 'Backup canceled.' : 'Backup saved: ${file.path.split('/').last}'),
      ),
    );
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirmImport(context);
    if (!confirmed) return;

    final passphrase = await _askPassphrase(context, title: 'Enter backup password');
    if (passphrase == null || passphrase.trim().isEmpty) return;

    final exportService = ref.read(exportServiceProvider);
    try {
      final count = await exportService.importEncryptedBackup(passphrase: passphrase.trim());
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(count == 0 ? 'Import canceled.' : 'Imported $count entries.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $error')),
      );
    }
  }

  Future<String?> _askPassphrase(BuildContext context, {required String title}) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    final strengthNotifier = ValueNotifier<double>(0);
    final matchNotifier = ValueNotifier<bool>(false);

    void updateState() {
      final strength = _passwordStrength(controller.text);
      strengthNotifier.value = strength;
      matchNotifier.value = controller.text.isNotEmpty && controller.text == confirmController.text;
    }

    controller.addListener(updateState);
    confirmController.addListener(updateState);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Create a backup password',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Confirm password',
                  ),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<double>(
                  valueListenable: strengthNotifier,
                  builder: (context, strength, _) {
                    final color = _strengthColor(context, strength);
                    final label = _strengthLabel(strength);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Strength: $label'),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 6,
                            value: strength,
                            color: color,
                            backgroundColor: Theme.of(context).dividerColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: matchNotifier,
                  builder: (context, matches, _) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        matches ? 'Passwords match' : 'Passwords must match',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: matches
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ValueListenableBuilder<double>(
            valueListenable: strengthNotifier,
            builder: (context, strength, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: matchNotifier,
                builder: (context, matches, __) {
                  final enabled = matches && strength >= 0.6;
                  return ElevatedButton(
                    onPressed: enabled ? () => Navigator.of(context).pop(controller.text) : null,
                    child: const Text('Continue'),
                  );
                },
              );
            },
          ),
        ],
      ),
    );

    controller.dispose();
    confirmController.dispose();
    strengthNotifier.dispose();
    matchNotifier.dispose();
    return result;
  }

  Future<bool> _confirmImport(BuildContext context) async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Replace current entries?'),
            content: const Text('Importing will overwrite existing entries on this device.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Import')),
            ],
          ),
        )) ??
        false;
  }
}

double _passwordStrength(String value) {
  if (value.isEmpty) return 0;
  var score = 0.0;
  if (value.length >= 12) score += 0.35;
  if (value.length >= 16) score += 0.15;
  if (RegExp(r'[A-Z]').hasMatch(value)) score += 0.15;
  if (RegExp(r'[a-z]').hasMatch(value)) score += 0.1;
  if (RegExp(r'[0-9]').hasMatch(value)) score += 0.1;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score += 0.15;
  return score.clamp(0, 1);
}

String _strengthLabel(double strength) {
  if (strength >= 0.85) return 'Excellent';
  if (strength >= 0.7) return 'Strong';
  if (strength >= 0.55) return 'Okay';
  if (strength >= 0.35) return 'Weak';
  return 'Very weak';
}

Color _strengthColor(BuildContext context, double strength) {
  if (strength >= 0.7) return Theme.of(context).colorScheme.secondary;
  if (strength >= 0.55) return Colors.orangeAccent;
  if (strength >= 0.35) return Colors.deepOrangeAccent;
  return Colors.redAccent;
}

class _AiSettingsCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AiSettingsCard> createState() => _AiSettingsCardState();
}

class _AiSettingsCardState extends ConsumerState<_AiSettingsCard> {
  final _controller = TextEditingController();
  bool _saved = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    ref.read(aiServiceProvider).getApiKey().then((key) {
      if (mounted && key != null) {
        _controller.text = key;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(aiServiceProvider).saveApiKey(_controller.text);
    if (!mounted) return;
    setState(() => _saved = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, size: 18, color: accent),
              const SizedBox(width: 8),
              Text('AI features', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Paste your Claude API key to enable writing prompts and AI reflections. Your key is stored on-device only.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            decoration: InputDecoration(
              hintText: 'sk-ant-…',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save key'),
              ),
              if (_saved) ...[
                const SizedBox(width: 12),
                Icon(Icons.check_circle_outline, color: accent, size: 18),
                const SizedBox(width: 4),
                Text('Saved', style: theme.textTheme.bodySmall?.copyWith(color: accent)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: selected
          ? Icon(Icons.check_circle, color: theme.colorScheme.secondary)
          : Icon(Icons.circle_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      onTap: onTap,
    );
  }
}
