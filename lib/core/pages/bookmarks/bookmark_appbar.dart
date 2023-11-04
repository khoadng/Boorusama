// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
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

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
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
                  ref.bookmarks.exportAllBookmarks();
                  break;
                default:
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'download_all',
                  child: Text(
                      'Download ${ref.watch(filteredBookmarksProvider).length} bookmarks'),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Text('Export'),
                ),
              ];
            },
          ),
      ],
    );
  }
}
