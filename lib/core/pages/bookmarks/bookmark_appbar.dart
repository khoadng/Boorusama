// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'providers.dart';

class BookmarkAppBar extends ConsumerWidget {
  const BookmarkAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final edit = ref.watch(bookmarkEditProvider);
    final hasBookmarks = ref.watch(hasBookmarkProvider);

    return AppBar(
      title: const Text('Bookmarks'),
      automaticallyImplyLeading: !edit,
      leading: edit
          ? IconButton(
              onPressed: () =>
                  ref.read(bookmarkEditProvider.notifier).state = false,
              icon: Icon(
                Icons.check,
                color: context.theme.colorScheme.primary,
              ),
            )
          : null,
      actions: [
        if (!edit)
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  ref.read(bookmarkEditProvider.notifier).state = true;
                  break;
                case 'download_all':
                  ref.bookmarks
                      .downloadBookmarks(ref.read(filteredBookmarksProvider));
                  break;
                case 'export':
                  _pickFolder(ref);
                  break;
                case 'import':
                  _pickFile(ref);
                default:
              }
            },
            itemBuilder: (context) {
              return [
                if (hasBookmarks)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                if (hasBookmarks)
                  PopupMenuItem(
                    value: 'download_all',
                    child: Text(
                        'Download ${ref.watch(filteredBookmarksProvider).length} bookmarks'),
                  ),
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
      ],
    );
  }

  void _pickFolder(WidgetRef ref) async {
    final path = await FilePicker.platform.getDirectoryPath();

    if (path != null) {
      ref.bookmarks.exportAllBookmarks(path);
    }
  }

  void _pickFile(WidgetRef ref) async {
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
}
