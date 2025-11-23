// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../foundation/html.dart';
import '../../../foundation/info/device_info.dart';
import '../../../foundation/picker.dart';
import '../../downloads/path/types.dart';
import '../../settings/providers.dart';
import '../../settings/widgets.dart';
import '../../themes/theme/types.dart';
import '../../widgets/widgets.dart';
import '../zip/providers.dart';
import 'providers.dart';
import 'types.dart';

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

    final hasValidPath = storagePath != null;
    final canEnableAutoBackup = !isLoading && hasValidPath;

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
              value: settings.enabled && hasValidPath,
              onChanged: canEnableAutoBackup
                  ? (enabled) => _updateSettings(
                      settingsNotifier,
                      settings.copyWith(enabled: enabled),
                    )
                  : null,
            ),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(context.t.settings.auto_backup.backup_location),
              subtitle: Text(
                ref
                    .watch(autoBackupDefaultDirectoryPathProvider)
                    .when(
                      data: (defaultPath) =>
                          settings.userSelectedPath ??
                          defaultPath ??
                          'No location selected'.hc,
                      loading: () =>
                          context.t.settings.data_and_storage.loading,
                      error: (_, _) => context.t.generic.errors.unknown,
                    ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.hintColor,
                ),
              ),
              trailing: TextButton(
                onPressed: () => pickDirectoryPathToastOnError(
                  context: context,
                  onPick: (path) => _updateSettings(
                    settingsNotifier,
                    settings.copyWith(userSelectedPath: () => path),
                  ),
                  initialDirectory:
                      settings.userSelectedPath ??
                      ref.read(autoBackupDefaultDirectoryPathProvider).value,
                ),
                child: Text(
                  ref
                      .watch(autoBackupDefaultDirectoryPathProvider)
                      .maybeWhen(
                        data: (defaultPath) =>
                            settings.userSelectedPath != null ||
                                defaultPath != null
                            ? context.t.settings.auto_backup.change
                            : context.t.generic.action.select,
                        orElse: () => context.t.settings.auto_backup.change,
                      ),
                ),
              ),
            ),
            if (!hasValidPath) const _SelectLocationRequestBanner(),
            //FIXME: Migrate folder selection warning to a common widget
            _DownloadPathWarning(
              padding: const EdgeInsets.all(12),
              storagePath: storagePath,
            ),
            if (settings.enabled && hasValidPath) ...[
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

class _SelectLocationRequestBanner extends StatelessWidget {
  const _SelectLocationRequestBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      margin: const EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Please select a backup location to enable auto backup'.hc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
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

class _DownloadPathWarning extends ConsumerWidget {
  const _DownloadPathWarning({
    required this.storagePath,
    this.padding,
  });

  final String? storagePath;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathInfo = PathInfo.from(storagePath);
    final deviceInfo = ref.watch(deviceInfoProvider);

    final shouldShow = switch (pathInfo) {
      AndroidPathInfo() => pathInfo.requiresPublicDirectory(
        deviceInfo.androidDeviceInfo?.version.sdkInt,
      ),
      InvalidPath() => true,
      _ => false,
    };

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    final releaseName =
        deviceInfo.androidDeviceInfo?.version.release ?? 'Unknown';

    return WarningContainer(
      margin: padding,
      contentBuilder: (context) => AppHtml(
        data: context.t.download.folder_select_warning
            .replaceAll(
              '{0}',
              AndroidPathInfo.allowedDownloadFolders.join(', '),
            )
            .replaceAll('{1}', releaseName),
      ),
    );
  }
}
