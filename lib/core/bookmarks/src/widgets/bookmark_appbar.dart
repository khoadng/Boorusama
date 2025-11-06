// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../core/widgets/widgets.dart';
import '../../../configs/config/providers.dart';
import '../../../posts/listing/providers.dart';
import '../data/bookmark_convert.dart';
import '../providers/bookmark_provider.dart';
import '../providers/local_providers.dart';

class BookmarkAppBar extends ConsumerWidget {
  const BookmarkAppBar({
    required this.controller,
    super.key,
  });

  final PostGridController<BookmarkPost> controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final edit = ref.watch(bookmarkEditProvider);
    final auth = ref.watchConfigAuth;
    final download = ref.watchConfigDownload;

    return AppBar(
      title: Text(context.t.bookmark.title),
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
          ValueListenableBuilder(
            valueListenable: controller.itemsNotifier,
            builder: (context, posts, child) => posts.isNotEmpty
                ? BooruPopupMenuButton(
                    items: [
                      BooruPopupMenuItem(
                        title: Text(context.t.generic.action.edit),
                        onTap: () {
                          ref.read(bookmarkEditProvider.notifier).state = true;
                        },
                      ),
                      BooruPopupMenuItem(
                        title: Text('Download ${posts.length} bookmarks'.hc),
                        onTap: () {
                          ref.bookmarks.downloadBookmarks(
                            auth,
                            download,
                            controller.items.map((e) => e.bookmark).toList(),
                          );
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
