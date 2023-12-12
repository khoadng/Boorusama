// Dart imports:
import 'dart:io';

// Flutter imports:
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
          ],
        ),
      ),
    );
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
      ref.bookmarks.exportAllBookmarks(path);
    }
  }
}
