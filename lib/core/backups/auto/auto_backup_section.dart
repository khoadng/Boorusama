// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../foundation/picker.dart';
import '../../settings/providers.dart';
import '../../settings/widgets.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../zip/providers.dart';
import 'auto_backup_settings.dart';

class AutoBackupSection extends ConsumerWidget {
  const AutoBackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider.select((s) => s.autoBackup));
    final settingsNotifier = ref.watch(settingsNotifierProvider.notifier);
    final isLoading = ref.watch(
      backupProvider.select((s) => s.isActive),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            BooruSwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(context.t.settings.auto_backup.enable_auto_backup),
              value: settings.enabled,
              onChanged: isLoading
                  ? null
                  : (enabled) => _updateSettings(
                      settingsNotifier,
                      settings.copyWith(enabled: enabled),
                    ),
            ),
            if (settings.enabled) ...[
              SettingsTile(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(context.t.settings.auto_backup.backup_frequency),
                selectedOption: settings.frequency,
                items: AutoBackupFrequency.values,
                onChanged: (frequency) => _updateSettings(
                  settingsNotifier,
                  settings.copyWith(frequency: frequency),
                ),
                optionBuilder: (frequency) =>
                    Text(_getFrequencyLabel(context, frequency)),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(context.t.settings.auto_backup.backup_location),
                subtitle: Text(
                  _getLocationDisplay(context, settings),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.hintColor,
                  ),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    await pickDirectoryPathToastOnError(
                      context: context,
                      onPick: (path) => _updateSettings(
                        settingsNotifier,
                        settings.copyWith(userSelectedPath: () => path),
                      ),
                    );
                  },

                  child: Text(context.t.settings.auto_backup.change),
                ),
              ),
              SettingsTile(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(context.t.settings.auto_backup.maximum_backups),
                selectedOption: settings.maxBackups,
                items: const [2, 3, 4, 5],
                onChanged: (maxBackups) => _updateSettings(
                  settingsNotifier,
                  settings.copyWith(maxBackups: maxBackups),
                ),
                optionBuilder: (count) =>
                    Text(context.t.settings.auto_backup.backup_count(n: count)),
              ),
              const Divider(height: 1),
              _buildStatusTile(context, ref, settings, isLoading),
            ],
          ],
        ),
      ),
    );
  }

  void _updateSettings(
    SettingsNotifier settingsNotifier,
    AutoBackupSettings newAutoBackup,
  ) {
    settingsNotifier.updateWith(
      (s) => s.copyWith(autoBackup: newAutoBackup),
    );
  }

  Widget _buildStatusTile(
    BuildContext context,
    WidgetRef ref,
    AutoBackupSettings settings,
    bool isLoading,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        context.t.settings.auto_backup.last_backup(
          lastBackup: _getLastBackupDisplay(context, settings),
        ),
      ),
      subtitle: Text(
        settings.shouldBackup
            ? context.t.settings.auto_backup.backup_needed
            : context.t.settings.auto_backup.up_to_date,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: settings.shouldBackup
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(context.t.settings.auto_backup.backing_up),
              ],
            )
          : FilledButton(
              onPressed: () async {
                await ref
                    .read(backupProvider.notifier)
                    .performManualAutoBackup(settings);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(context.t.settings.auto_backup.backup_now),
            ),
    );
  }

  String _getFrequencyLabel(
    BuildContext context,
    AutoBackupFrequency frequency,
  ) {
    switch (frequency) {
      case AutoBackupFrequency.daily:
        return context.t.settings.auto_backup.frequency.daily;
      case AutoBackupFrequency.weekly:
        return context.t.settings.auto_backup.frequency.weekly;
    }
  }
}

String _getLocationDisplay(BuildContext context, AutoBackupSettings settings) {
  return settings.userSelectedPath ??
      context.t.settings.backup_and_restore.default_backup_location;
}

String _getLastBackupDisplay(
  BuildContext context,
  AutoBackupSettings settings,
) {
  if (settings.lastBackupTime == null) {
    return context.t.settings.backup_and_restore.never;
  }

  final now = DateTime.now();
  final diff = now.difference(settings.lastBackupTime!);

  if (diff.inDays > 0) {
    return context.t.settings.backup_and_restore.days_ago.replaceAll(
      '{days}',
      diff.inDays.toString(),
    );
  } else if (diff.inHours > 0) {
    return context.t.settings.backup_and_restore.hours_ago.replaceAll(
      '{hours}',
      diff.inHours.toString(),
    );
  } else if (diff.inMinutes > 0) {
    return context.t.settings.backup_and_restore.minutes_ago.replaceAll(
      '{minutes}',
      diff.inMinutes.toString(),
    );
  } else {
    return context.t.settings.backup_and_restore.just_now;
  }
}
