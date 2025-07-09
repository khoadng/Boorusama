// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' show join;

// Project imports:
import '../../../../../foundation/clipboard.dart';
import '../../../../../foundation/info/device_info.dart';
import '../../../../../foundation/info/package_info.dart';
import '../../../../../foundation/path.dart' as p;
import '../../../../../foundation/picker.dart';
import '../../../../../foundation/platform.dart';
import '../../../../../foundation/toast.dart';
import '../../../../backups/routes.dart';
import '../../../../backups/sync_data_page.dart';
import '../../../../blacklists/providers.dart';
import '../../../../bookmarks/providers.dart';
import '../../../../bulk_downloads/providers.dart';
import '../../../../config_widgets/booru_logo.dart';
import '../../../../configs/config.dart';
import '../../../../configs/export_import/types.dart';
import '../../../../configs/manage/providers.dart';
import '../../../../router.dart';
import '../../../../search/histories/providers.dart';
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
      title: Text(context.t.settings.backup_and_restore.backup_and_restore),
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
        _buildSearchHistories(),
        const SizedBox(height: 8),
        _buildBulkDownloads(),
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
              ref
                  .read(booruConfigProvider.notifier)
                  .exportClipboard(
                    onSuccess: (message) => showSuccessToast(context, message),
                    onFailure: (message) => showErrorToast(context, message),
                    appVersion: ref.read(appVersionProvider),
                  );
            case 'import_clipboard':
              ref
                  .read(booruConfigProvider.notifier)
                  .importClipboard(
                    onSuccess: _onImportSuccess,
                    onWillImport: _showImportBooruConfigsAlertDialog,
                    onFailure: (message) => showErrorToast(context, message),
                  );
            default:
          }
        },
        itemBuilder: {
          if (configs.isNotEmpty) 'export': Text('Export'.hc),
          'import': Text('Import'.hc),
          if (configs.isNotEmpty)
            'export_clipboard': Text('Export to clipboard'.hc),
          'import_clipboard': Text('Import from clipboard'.hc),
        },
      ),
    );
  }

  Widget _buildBlacklistedTags() {
    final blacklistedTags = ref.watch(globalBlacklistedTagsProvider);

    return BackupRestoreTile(
      leadingIcon: Symbols.tag,
      title: 'Blacklisted tags'.hc,
      subtitle: '${blacklistedTags.length} tags'.hc,
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
      title: context.t.favorite_tags.favorite_tags,
      subtitle: '${tags.length} tags'.hc,
      trailing: BooruPopupMenuButton(
        onSelected: (value) {
          if (value == 'import') {
            goToFavoriteTagImportPage(context);
          } else if (value == 'export') {
            ref
                .read(favoriteTagsProvider.notifier)
                .export(
                  onDone: (tagString) {
                    AppClipboard.copyAndToast(
                      context,
                      tagString,
                      message: context.t.favorite_tags.export_notification,
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
          if (tags.isNotEmpty) 'export': Text(context.t.favorite_tags.export),
          'import': Text(context.t.favorite_tags.import),
          if (tags.isNotEmpty)
            'export_with_labels': Text('Export with labels'.hc),
          'import_with_labels': Text('Import with labels'.hc),
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
          if (hasBookmarks) 'export': Text('Export'.hc),
          'import': Text('Import'.hc),
        },
      ),
    );
  }

  Widget _buildSettings() {
    return BackupRestoreTile(
      leadingIcon: Symbols.settings,
      title: 'Settings'.hc,
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
        itemBuilder: {
          'export': Text('Export'.hc),
          'import': Text('Import'.hc),
        },
      ),
    );
  }

  Widget _buildSearchHistories() {
    return BackupRestoreTile(
      leadingIcon: Symbols.history,
      title: 'Search histories'.hc,
      trailing: BooruPopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case 'export':
              _pickSearchHistoryFolder(ref);
            case 'import':
              _pickSearchHistoryFile(ref);
            default:
          }
        },
        itemBuilder: {
          'export': Text('Export'.hc),
          'import': Text('Import'.hc),
        },
      ),
    );
  }

  Widget _buildBulkDownloads() {
    return BackupRestoreTile(
      leadingIcon: Symbols.folder_zip,
      title: 'Bulk downloads'.hc,
      trailing: BooruPopupMenuButton(
        onSelected: (value) {
          switch (value) {
            case 'export':
              _pickBulkDownloadsFolder(ref);
            case 'import':
              _pickBulkDownloadsFile(ref);
            default:
          }
        },
        itemBuilder: {
          'export': Text('Export'.hc),
          'import': Text('Import'.hc),
        },
      ),
    );
  }

  Future<void> _pickSearchHistoryFolder(WidgetRef ref) =>
      pickDirectoryPathToastOnError(
        context: context,
        onPick: (path) async {
          try {
            final dbPath = await getSearchHistoryDbPath();
            final file = File(dbPath);
            if (!file.existsSync()) {
              _showErrorToast('No search history found'.hc);
              return;
            }

            final destinationPath = join(path, kSearchHistoryDbName);
            await file.copy(destinationPath);
            _showSuccessToast('Search history exported successfully'.hc);
          } catch (e) {
            _showErrorToast('Failed to export search history'.hc);
          }
        },
      );

  void _pickSearchHistoryFile(WidgetRef ref) => _pickFile(
    allowedExtensions: ['db'],
    forceAnyFileType: true,
    onPick: (path) async {
      try {
        final sourceFile = File(path);

        // Check SQLite header magic number
        final bytes = await sourceFile.openRead(0, 16).first;
        final header = bytes.take(16).toList();
        if (!_isSQLiteFile(header)) {
          _showErrorToast('Invalid database file');
          return;
        }

        final dbPath = await getSearchHistoryDbPath();
        final destFile = File(dbPath);

        if (destFile.existsSync()) {
          await destFile.delete();
        }

        await sourceFile.copy(dbPath);
        _showSuccessToast('Search history imported successfully');

        ref.invalidate(searchHistoryRepoProvider);
      } catch (e) {
        _showErrorToast('Failed to import search history');
      }
    },
  );

  Future<void> _pickBulkDownloadsFolder(WidgetRef ref) =>
      pickDirectoryPathToastOnError(
        context: context,
        onPick: (path) async {
          try {
            final dbPath = await getDownloadsDbPath();
            final file = File(dbPath);
            if (!file.existsSync()) {
              _showErrorToast('No bulk downloads found'.hc);
              return;
            }

            final destinationPath = join(path, kDownloadDbName);
            await file.copy(destinationPath);
            _showSuccessToast('Bulk downloads exported successfully'.hc);
          } catch (e) {
            _showErrorToast('Failed to export bulk downloads'.hc);
          }
        },
      );

  void _pickBulkDownloadsFile(WidgetRef ref) => _pickFile(
    onPick: (path) async {
      try {
        final sourceFile = File(path);

        // Check SQLite header magic number
        final bytes = await sourceFile.openRead(0, 16).first;
        final header = bytes.take(16).toList();
        if (!_isSQLiteFile(header)) {
          _showErrorToast('Invalid database file');
          return;
        }

        final dbPath = await getDownloadsDbPath();

        final destFile = File(dbPath);

        if (destFile.existsSync()) {
          await destFile.delete();
        }

        await sourceFile.copy(dbPath);

        _showSuccessToast('Bulk downloads imported successfully');

        ref.invalidate(internalDownloadRepositoryProvider);
      } catch (e) {
        _showErrorToast('Failed to import bulk downloads');
      }
    },
  );

  // SQLite files start with "SQLite format 3\0"
  bool _isSQLiteFile(List<int> header) {
    const sqliteHeader = [
      0x53,
      0x51,
      0x4C,
      0x69,
      0x74,
      0x65,
      0x20,
      0x66,
      0x6F,
      0x72,
      0x6D,
      0x61,
      0x74,
      0x20,
      0x33,
      0x00,
    ];
    if (header.length < 16) return false;
    for (var i = 0; i < 16; i++) {
      if (header[i] != sqliteHeader[i]) return false;
    }
    return true;
  }

  void _showErrorToast(String message) {
    if (context.mounted) {
      showErrorToast(context, message);
    }
  }

  void _showSuccessToast(String message) {
    if (context.mounted) {
      showSuccessToast(context, message);
    }
  }

  Future<bool> _showImportBooruConfigsAlertDialog(
    BooruConfigExportData data,
  ) async {
    final result = await showDialog<bool?>(
      context: context,
      routeSettings: const RouteSettings(name: 'booru_import_overwrite_alert'),
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
          ref
              .read(booruConfigProvider.notifier)
              .export(
                path: path,
                onSuccess: (message) => showSuccessToast(context, message),
                onFailure: (message) => showErrorToast(context, message),
              );
        },
      );

  Future<void> _pickFile({
    required void Function(String path) onPick,
    List<String> allowedExtensions = const ['json'],
    bool forceAnyFileType = false,
  }) {
    if (forceAnyFileType) {
      return _pickFileManualExtensionCheck(allowedExtensions, onPick);
    }

    if (isAndroid()) {
      final androidVersion = ref
          .read(deviceInfoProvider)
          .androidDeviceInfo
          ?.version
          .sdkInt;
      // Android 9 or lower will need to use any file type
      if (androidVersion != null &&
          androidVersion <= AndroidVersions.android9) {
        return _pickFileManualExtensionCheck(allowedExtensions, onPick);
      }
    }

    return pickSingleFilePathToastOnError(
      context: context,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      onPick: onPick,
    );
  }

  Future<void> _pickFileManualExtensionCheck(
    List<String> allowedExtensions,
    void Function(String path) onPick,
  ) => pickSingleFilePathToastOnError(
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

  void _pickProfileFile(WidgetRef ref) => _pickFile(
    onPick: (path) {
      ref
          .read(booruConfigProvider.notifier)
          .import(
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
      ref
          .read(settingsNotifierProvider.notifier)
          .importSettings(
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
          ref
              .read(favoriteTagsProvider.notifier)
              .exportWithLabels(
                context: context,
                path: path,
              );
        },
      );

  void _pickFavoriteTagsFile(WidgetRef ref) => _pickFile(
    onPick: (path) {
      ref
          .read(favoriteTagsProvider.notifier)
          .importWithLabels(
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
