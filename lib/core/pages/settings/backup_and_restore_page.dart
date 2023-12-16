// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/pages/bookmarks/providers.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

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
    final hasBookmarks = ref.watch(hasBookmarkProvider);
    final tags = ref.watch(favoriteTagsProvider);
    final blacklistedTags = ref.watch(globalBlacklistedTagsProvider);

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('Backup and Restore'),
        ),
        body: child,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Bookmarks'),
              trailing: PopupMenuButton(
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
                itemBuilder: (context) {
                  return [
                    if (hasBookmarks)
                      const PopupMenuItem(
                        value: 'export',
                        child: Text('Export'),
                      ),
                    const PopupMenuItem(
                      value: 'import',
                      child: Text('Import'),
                    ),
                  ];
                },
              ),
            ),
            ListTile(
              title: const Text('Favorite tags'),
              trailing: PopupMenuButton(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                onSelected: (value) {
                  if (value == 'import') {
                    goToFavoriteTagImportPage(context);
                  } else if (value == 'export') {
                    ref.read(favoriteTagsProvider.notifier).export(
                      onDone: (tagString) {
                        Clipboard.setData(
                          ClipboardData(text: tagString),
                        ).then((value) => showSimpleSnackBar(
                              context: context,
                              content: const Text(
                                'favorite_tags.export_notification',
                              ).tr(),
                            ));
                      },
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'import',
                    child: const Text('favorite_tags.import').tr(),
                  ),
                  if (tags.isNotEmpty)
                    PopupMenuItem(
                      value: 'export',
                      child: const Text('favorite_tags.export').tr(),
                    ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Blacklisted tags'),
              trailing: ImportExportTagButton(
                onImport: (tagString) => ref
                    .read(globalBlacklistedTagsProvider.notifier)
                    .addTagStringWithToast(tagString),
                tags: blacklistedTags.map((e) => e.name).toList(),
              ),
            ),
            ListTile(
              title: const Text('Profiles'),
              trailing: PopupMenuButton(
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
                            onSuccess: (message) => showSuccessToast(message),
                            onFailure: (message) => showErrorToast(message),
                          );
                      break;
                    case 'import_clipboard':
                      ref.read(booruConfigProvider.notifier).importClipboard(
                            onSuccess: _onImportSuccess,
                            onWillImport: _showImportBooruConfigsAlertDialog,
                            onFailure: (message) => showErrorToast(message),
                          );
                      break;
                    default:
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: 'export',
                      child: Text('Export to file'),
                    ),
                    const PopupMenuItem(
                      value: 'import',
                      child: Text('Import from file'),
                    ),
                    const PopupMenuItem(
                      value: 'export_clipboard',
                      child: Text('Export to clipboard'),
                    ),
                    const PopupMenuItem(
                      value: 'import_clipboard',
                      child: Text('Import from clipboard'),
                    ),
                  ];
                },
              ),
            ),
          ],
        ),
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

  void _pickBookmarkFolder(WidgetRef ref) async {
    final path = await FilePicker.platform.getDirectoryPath();

    if (path != null) {
      ref.bookmarks.exportAllBookmarks(path);
    }
  }

  void _pickBookmarkFile(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      final path = result.files.single.path;
      if (path != null) {
        final file = File(path);
        ref.bookmarks.importBookmarks(file);
      } else {
        // User canceled the picker
      }
    }
  }

  void _pickProfileFolder(WidgetRef ref) async {
    final path = await FilePicker.platform.getDirectoryPath();

    if (path != null) {
      ref.read(booruConfigProvider.notifier).export(
            path: path,
            onSuccess: (message) => showSuccessToast(message),
            onFailure: (message) => showErrorToast(message),
          );
    }
  }

  void _pickProfileFile(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      final path = result.files.single.path;
      if (path != null) {
        ref.read(booruConfigProvider.notifier).import(
              path: path,
              onSuccess: _onImportSuccess,
              onWillImport: _showImportBooruConfigsAlertDialog,
              onFailure: (message) => showErrorToast(message),
            );
      } else {
        // User canceled the picker
      }
    }
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    color: Theme.of(context).colorScheme.onBackground,
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
