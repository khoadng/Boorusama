// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../foundation/html.dart';
import '../../../foundation/info/device_info.dart';
import '../../../foundation/picker.dart';
import '../../../foundation/platform.dart';
import '../../settings/providers.dart';
import '../../settings/widgets.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../downloads/path/validator.dart';
import '../auto/auto_backup_service.dart';
import '../zip/providers.dart';
import 'auto_backup_settings.dart';

class AutoBackupSection extends ConsumerWidget {
  const AutoBackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(settingsProvider.select((s) => s.autoBackup));
    final settingsNotifier = ref.watch(settingsNotifierProvider.notifier);
    final isLoading = ref.watch(
      backupProvider.select((s) => s.isActive),
    );
    final storagePath = ref
        .watch(autoBackupDefaultDirectoryPathProvider)
        .maybeWhen(
          data: (defaultPath) => settings.userSelectedPath ?? defaultPath,
          orElse: () => null,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: colorScheme.surfaceContainer,
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
                optionBuilder: (frequency) => Text(
                  switch (frequency) {
                    AutoBackupFrequency.daily =>
                      context.t.settings.auto_backup.frequency.daily,
                    AutoBackupFrequency.weekly =>
                      context.t.settings.auto_backup.frequency.weekly,
                  },
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(context.t.settings.auto_backup.backup_location),
                subtitle: Text(
                  ref
                      .watch(autoBackupDefaultDirectoryPathProvider)
                      .when(
                        data: (path) => settings.userSelectedPath ?? path,
                        loading: () =>
                            context.t.settings.data_and_storage.loading,
                        error: (_, _) => context.t.generic.errors.unknown,
                      ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.hintColor,
                  ),
                ),
                trailing: TextButton(
                  onPressed: ref
                      .watch(autoBackupDefaultDirectoryPathProvider)
                      .maybeWhen(
                        data: (path) =>
                            () => pickDirectoryPathToastOnError(
                              context: context,
                              onPick: (path) => _updateSettings(
                                settingsNotifier,
                                settings.copyWith(userSelectedPath: () => path),
                              ),
                              initialDirectory:
                                  settings.userSelectedPath ?? path,
                            ),
                        orElse: () => null,
                      ),
                  child: Text(context.t.settings.auto_backup.change),
                ),
              ),
              //FIXME: Migrate folder selection warning to a common widget
              _DownloadPathWarning(
                padding: const EdgeInsets.all(12),
                storagePath: storagePath,
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
              const _StatusTile(),
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
}

class _StatusTile extends ConsumerWidget {
  const _StatusTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = ref.watch(
      backupProvider.select((s) => s.isActive),
    );
    final settings = ref.watch(settingsProvider.select((s) => s.autoBackup));

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
        style: theme.textTheme.bodySmall?.copyWith(
          color: settings.shouldBackup
              ? colorScheme.error
              : colorScheme.primary,
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
}

String _getLastBackupDisplay(
  BuildContext context,
  AutoBackupSettings settings,
) => switch (settings.lastBackupTime) {
  null => context.t.settings.backup_and_restore.never,
  final time => switch (DateTime.now().difference(time)) {
    final diff when diff.inDays > 0 => context.t.time.timeago.days.replaceAll(
      '{days}',
      diff.inDays.toString(),
    ),
    final diff when diff.inHours > 0 => context.t.time.timeago.hours.replaceAll(
      '{hours}',
      diff.inHours.toString(),
    ),
    final diff when diff.inMinutes > 0 =>
      context.t.time.timeago.minutes.replaceAll(
        '{minutes}',
        diff.inMinutes.toString(),
      ),
    _ => context.t.time.timeago.just_now,
  },
};

class _DownloadPathWarning extends ConsumerWidget
    with DownloadPathValidatorMixin {
  const _DownloadPathWarning({
    required this.storagePath,
    this.padding,
  });

  @override
  final String? storagePath;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isAndroid()) {
      return const SizedBox.shrink();
    }

    final deviceInfo = ref.watch(deviceInfoProvider);
    final hasScopeStorage =
        hasScopedStorage(
          deviceInfo.androidDeviceInfo?.version.sdkInt,
        ) ??
        true;

    if (!shouldDisplayWarning(hasScopeStorage: hasScopeStorage)) {
      return const SizedBox.shrink();
    }

    final releaseName =
        deviceInfo.androidDeviceInfo?.version.release ?? 'Unknown';

    return WarningContainer(
      margin: padding,
      contentBuilder: (context) => AppHtml(
        data: context.t.download.folder_select_warning
            .replaceAll('{0}', allowedFolders.join(', '))
            .replaceAll('{1}', releaseName),
      ),
    );
  }
}
