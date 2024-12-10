// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/widgets/widgets.dart';
import '../../configs/ref.dart';
import '../bookmark_provider.dart';
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
                Symbols.check,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : null,
      actions: [
        if (!edit)
          BooruPopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  ref.read(bookmarkEditProvider.notifier).state = true;
                  break;
                case 'download_all':
                  ref.bookmarks.downloadBookmarks(
                    ref.readConfig,
                    ref.read(filteredBookmarksProvider),
                  );
                  break;
              }
            },
            itemBuilder: {
              if (hasBookmarks) 'edit': const Text('Edit'),
              if (hasBookmarks)
                'download_all': Text(
                  'Download ${ref.watch(filteredBookmarksProvider).length} bookmarks',
                ),
            },
          ),
      ],
    );
  }
}
