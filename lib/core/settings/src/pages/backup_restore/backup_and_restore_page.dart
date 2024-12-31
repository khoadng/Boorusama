// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../backups/routes.dart';
import '../../../../backups/sync_data_page.dart';
import '../../../../blacklists/providers.dart';
import '../../../../bookmarks/providers.dart';
import '../../../../configs/config.dart';
import '../../../../configs/manage.dart';
import '../../../../foundation/clipboard.dart';
import '../../../../foundation/path.dart' as p;
import '../../../../foundation/picker.dart';
import '../../../../foundation/platform.dart';
import '../../../../foundation/toast.dart';
import '../../../../info/device_info.dart';
import '../../../../info/package_info.dart';
import '../../../../router.dart';
import '../../../../tags/favorites/providers.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/widgets.dart';
import '../../providers/settings_notifier.dart';
import '../../widgets/settings_page_scaffold.dart';
import 'backup_restore_tile.dart';
import 'import_booru_configs_alert_dialog.dart';

class BackupAndRestorePage extends ConsumerStatefulWidget {
  const BackupAndRestorePage({
    super.key,
  });

  @override
  ConsumerState<BackupAndRestorePage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<BackupAndRestorePage> {
  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: const Text('settings.backup_and_restore.backup_and_restore').tr(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        const _Title(
          title: 'Transfer data',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 12,
            children: [
              Expanded(
                child: DataTransferCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.paperPlane,
                  ),
                  title: 'Send',
                  onPressed: () {
                    goToSyncDataPage(context, mode: TransferMode.export);
                  },
                ),
              ),
              Expanded(
                child: DataTransferCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.download,
                  ),
                  title: 'Receive',
                  onPressed: () {
                    goToSyncDataPage(context, mode: TransferMode.import);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _Title(
          title: 'Manual backup',
        ),
        const SizedBox(height: 8),
        _buildProfiles(),
        const SizedBox(height: 8),
        _buildFavoriteTags(),
        const SizedBox(height: 8),
        _buildBookmark(),
        const SizedBox(height: 8),
        _buildBlacklistedTags(),
        const SizedBox(height: 8),
        _buildSettings(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProfiles() {
    final configs = ref.watch(booruConfigProvider);
    final first5Configs = configs.take(5).toList();

    return BackupRestoreTile(
      leadingIcon: Symbols.settings,
      title: 'Booru profiles',
      subtitle: '${configs.length} profiles',
      extra: first5Configs.isNotEmpty
          ? [
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...first5Configs.map(
                    (e) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BooruLogo.fromConfig(e.auth),
                    ),
                  ),
                  if (first5Configs.length < configs.length)
                    Text(
                      '+${configs.length - first5Configs.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ]
          : null,
      trailing: BooruPopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case 'export':
              _pickProfileFolder(ref);
            case 'import':
              _pickProfileFile(ref);
            case 'export_clipboard':
              ref.read(booruConfigProvider.notifier).exportClipboard(
                    onSuccess: (message) => showSuccessToast(context, message),
                    onFailure: (message) => showErrorToast(context, message),
                    appVersion: ref.read(appVersionProvider),
                  );
            case 'import_clipboard':
              ref.read(booruConfigProvider.notifier).importClipboard(
                    onSuccess: _onImportSuccess,
                    onWillImport: _showImportBooruConfigsAlertDialog,
                    onFailure: (message) => showErrorToast(context, message),
                  );
            default:
          }
        },
        itemBuilder: {
          if (configs.isNotEmpty) 'export': const Text('Export'),
          'import': const Text('Import'),
          if (configs.isNotEmpty)
            'export_clipboard': const Text('Export to clipboard'),
          'import_clipboard': const Text('Import from clipboard'),
        },
      ),
    );
  }

  Widget _buildBlacklistedTags() {
    final blacklistedTags = ref.watch(globalBlacklistedTagsProvider);

    return BackupRestoreTile(
      leadingIcon: Symbols.tag,
      title: 'Blacklisted tags',
      subtitle: '${blacklistedTags.length} tags',
      trailing: ImportExportTagButton(
        onImport: (tagString) => ref
            .read(globalBlacklistedTagsProvider.notifier)
            .addTagStringWithToast(context, tagString),
        tags: blacklistedTags.map((e) => e.name).toList(),
      ),
    );
  }

  Widget _buildFavoriteTags() {
    final tags = ref.watch(favoriteTagsProvider);

    return BackupRestoreTile(
      leadingIcon: Symbols.favorite,
      title: 'favorite_tags.favorite_tags'.tr(),
      subtitle: '${tags.length} tags',
      trailing: BooruPopupMenuButton(
        onSelected: (value) {
          if (value == 'import') {
            goToFavoriteTagImportPage(context);
          } else if (value == 'export') {
            ref.read(favoriteTagsProvider.notifier).export(
              onDone: (tagString) {
                AppClipboard.copyAndToast(
                  context,
                  tagString,
                  message: 'favorite_tags.export_notification'.tr(),
                );
              },
            );
          } else if (value == 'export_with_labels') {
            _pickFavoriteTagsFolder(ref);
          } else if (value == 'import_with_labels') {
            _pickFavoriteTagsFile(ref);
          }
        },
        itemBuilder: {
          if (tags.isNotEmpty)
            'export': const Text('favorite_tags.export').tr(),
          'import': const Text('favorite_tags.import').tr(),
          if (tags.isNotEmpty)
            'export_with_labels': const Text('Export with labels'),
          'import_with_labels': const Text('Import with labels'),
        },
      ),
    );
  }

  Widget _buildBookmark() {
    final hasBookmarks = ref.watch(hasBookmarkProvider);
    final bookmarks = ref.watch(bookmarkProvider).bookmarks;

    return BackupRestoreTile(
      leadingIcon: Symbols.bookmark,
      title: 'Bookmarks',
      subtitle: hasBookmarks ? '${bookmarks.length} bookmarks' : 'No bookmarks',
      trailing: BooruPopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case 'export':
              _pickBookmarkFolder(ref);
            case 'import':
              _pickBookmarkFile(ref);
            default:
          }
        },
        itemBuilder: {
          if (hasBookmarks) 'export': const Text('Export'),
          'import': const Text('Import'),
        },
      ),
    );
  }

  Widget _buildSettings() {
    return BackupRestoreTile(
      leadingIcon: Symbols.settings,
      title: 'Settings',
      trailing: BooruPopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case 'export':
              _pickSettingsFolder(ref);
            case 'import':
              _pickSettingsFile(ref);
            default:
          }
        },
        itemBuilder: const {
          'export': Text('Export'),
          'import': Text('Import'),
        },
      ),
    );
  }

  Future<bool> _showImportBooruConfigsAlertDialog(
    BooruConfigExportData data,
  ) async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => ImportBooruConfigsAlertDialog(data: data),
    );

    return result ?? false;
  }

  void _onImportSuccess(String message, List<BooruConfig> configs) {
    final config = configs.first;
    Reboot.start(
      context,
      RebootData(
        config: config,
        configs: configs,
        settings: ref.read(settingsNotifierProvider),
      ),
    );
  }

  Future<void> _pickBookmarkFolder(WidgetRef ref) =>
      pickDirectoryPathToastOnError(
        context: context,
        onPick: (path) {
          ref.bookmarks.exportAllBookmarks(context, path);
        },
      );

  void _pickBookmarkFile(WidgetRef ref) => _pickFile(
        onPick: (path) {
          final file = File(path);
          ref.bookmarks.importBookmarks(context, file);
        },
      );

  Future<void> _pickProfileFolder(WidgetRef ref) =>
      pickDirectoryPathToastOnError(
        context: context,
        onPick: (path) {
          ref.read(booruConfigProvider.notifier).export(
                path: path,
                onSuccess: (message) => showSuccessToast(context, message),
                onFailure: (message) => showErrorToast(context, message),
              );
        },
      );

  Future<void> _pickFile({
    required void Function(String path) onPick,
  }) {
    const allowedExtensions = ['json'];

    if (isAndroid()) {
      final androidVersion =
          ref.read(deviceInfoProvider).androidDeviceInfo?.version.sdkInt;
      // Android 9 or lower will need to use any file type
      if (androidVersion != null &&
          androidVersion <= AndroidVersions.android9) {
        return pickSingleFilePathToastOnError(
          context: context,
          onPick: (path) {
            final ext = p.extension(path);

            if (!allowedExtensions.contains(ext.substring(1))) {
              showErrorToast(
                context,
                'Invalid file type, only ${allowedExtensions.map((e) => '.$e').join(', ')} files are allowed',
              );
              return;
            }

            onPick(path);
          },
        );
      }
    }

    return pickSingleFilePathToastOnError(
      context: context,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      onPick: onPick,
    );
  }

  void _pickProfileFile(WidgetRef ref) => _pickFile(
        onPick: (path) {
          ref.read(booruConfigProvider.notifier).import(
                context: context,
                path: path,
                onSuccess: _onImportSuccess,
                onWillImport: _showImportBooruConfigsAlertDialog,
                onFailure: (message) => showErrorToast(context, message),
              );
        },
      );

  Future<void> _pickSettingsFolder(WidgetRef ref) =>
      pickDirectoryPathToastOnError(
        context: context,
        onPick: (path) {
          ref
              .read(settingsNotifierProvider.notifier)
              .exportSettings(context, path);
        },
      );

  void _pickSettingsFile(WidgetRef ref) => _pickFile(
        onPick: (path) {
          ref.read(settingsNotifierProvider.notifier).importSettings(
                context: context,
                path: path,
                onWillImport: (data) async => true,
                onFailure: (message) => showErrorToast(context, message),
                onSuccess: (message, _) {
                  showSuccessToast(context, message);
                },
              );
        },
      );

  Future<void> _pickFavoriteTagsFolder(WidgetRef ref) =>
      pickDirectoryPathToastOnError(
        context: context,
        onPick: (path) {
          ref.read(favoriteTagsProvider.notifier).exportWithLabels(
                context: context,
                path: path,
              );
        },
      );

  void _pickFavoriteTagsFile(WidgetRef ref) => _pickFile(
        onPick: (path) {
          ref.read(favoriteTagsProvider.notifier).importWithLabels(
                context: context,
                path: path,
              );
        },
      );
}

class _Title extends StatelessWidget {
  const _Title({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

class DataTransferCard extends StatelessWidget {
  const DataTransferCard({
    required this.icon,
    required this.title,
    required this.onPressed,
    super.key,
  });

  final Widget icon;
  final String title;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconTheme = theme.iconTheme;
    final borderRadius = BorderRadius.circular(16);

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Theme(
                  data: theme.copyWith(
                    iconTheme: iconTheme.copyWith(
                      size: 18,
                      color: theme.colorScheme.hintColor,
                    ),
                  ),
                  child: icon,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
