// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../core/widgets/widgets.dart';
import '../../../configs/ref.dart';
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

    final itemBuilder = {
      'edit': Text(context.t.generic.action.edit),
      'download_all': ValueListenableBuilder(
        valueListenable: controller.itemsNotifier,
        builder: (_, posts, _) => Text(
          'Download ${posts.length} bookmarks'.hc,
        ),
      ),
    };

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
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          ref.read(bookmarkEditProvider.notifier).state = true;
                        case 'download_all':
                          ref.bookmarks.downloadBookmarks(
                            auth,
                            download,
                            controller.items.map((e) => e.bookmark).toList(),
                          );
                      }
                    },
                    itemBuilder: itemBuilder,
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
