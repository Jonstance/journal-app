import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/services/export_service.dart';

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
                  'Your journal lives on-device by default. Sync is optional and will be end-to-end encrypted.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
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
                  'Ambient sounds and lock-screen widgets can be configured here.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Customize focus mode'),
                ),
              ],
            ),
          ),
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
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter a password you will remember',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
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
          : Icon(Icons.circle_outlined, color: theme.colorScheme.onSurface.withOpacity(0.4)),
      onTap: onTap,
    );
  }
}
