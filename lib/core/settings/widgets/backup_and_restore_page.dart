// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/export_import/export_import.dart';
import 'package:boorusama/core/favorited_tags/favorited_tags.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/foundation/path.dart' as p;
import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/settings_page_scaffold.dart';

class BackupAndRestorePage extends ConsumerStatefulWidget {
  const BackupAndRestorePage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<BackupAndRestorePage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<BackupAndRestorePage> {
  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      hasAppBar: widget.hasAppBar,
      title: const Text('settings.backup_and_restore.backup_and_restore').tr(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
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
      ],
    );
  }

  Widget _buildProfiles() {
    final configs = ref.watch(booruConfigProvider);
    final first5Configs = configs?.take(5).toList();

    return BackupRestoreTile(
      leadingIcon: Symbols.settings,
      title: 'Booru profiles',
      subtitle: '${configs?.length} profiles',
      extra: first5Configs != null && first5Configs.isNotEmpty
          ? [
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...first5Configs.map(
                    (e) => PostSource.from(e.url).whenWeb(
                      (source) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BooruLogo(source: source),
                      ),
                      () => const SizedBox.shrink(),
                    ),
                  ),
                  if (first5Configs.length < configs!.length)
                    Text(
                      '+${configs.length - first5Configs.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colorScheme.onSurface,
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
              break;
            case 'import':
              _pickProfileFile(ref);
              break;
            case 'export_clipboard':
              ref.read(booruConfigProvider.notifier).exportClipboard(
                    onSuccess: (message) => showSuccessToast(context, message),
                    onFailure: (message) => showErrorToast(context, message),
                    appVersion: ref.read(appVersionProvider),
                  );
              break;
            case 'import_clipboard':
              ref.read(booruConfigProvider.notifier).importClipboard(
                    onSuccess: _onImportSuccess,
                    onWillImport: _showImportBooruConfigsAlertDialog,
                    onFailure: (message) => showErrorToast(context, message),
                  );
              break;
            default:
          }
        },
        itemBuilder: {
          if (configs != null && configs.isNotEmpty)
            'export': const Text('Export'),
          'import': const Text('Import'),
          if (configs != null && configs.isNotEmpty)
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
                  message: 'favorite_tags.export_notification',
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
              break;
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
              break;
            case 'import':
              _pickSettingsFile(ref);
              break;
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
    Reboot.start(context, config);
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
          type: FileType.any,
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
          ref.read(settingsProvider.notifier).exportSettings(context, path);
        },
      );

  void _pickSettingsFile(WidgetRef ref) => _pickFile(
        onPick: (path) {
          ref.read(settingsProvider.notifier).importSettings(
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

class BackupRestoreTile extends StatelessWidget {
  const BackupRestoreTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.extra,
  });

  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final List<Widget>? extra;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: context.colorScheme.surface,
            child: Icon(
              leadingIcon,
              color: context.colorScheme.onSurface,
              fill: 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: context.theme.hintColor,
                    ),
                  ),
                if (extra != null) ...extra!,
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class ImportBooruConfigsAlertDialog extends StatelessWidget {
  const ImportBooruConfigsAlertDialog({
    super.key,
    required this.data,
  });

  final BooruConfigExportData data;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              'Importing ${data.data.length} profiles',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This will override ALL your current profiles, are you sure?',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.colorScheme.errorContainer,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Sure',
                  style: TextStyle(
                    color: context.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
