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
    final hasBookmarks = ref.watch(hasBookmarkProvider);

    final itemBuilder = {
      if (hasBookmarks) 'edit': Text('Edit'.hc),
      if (hasBookmarks)
        'download_all': ValueListenableBuilder(
          valueListenable: controller.itemsNotifier,
          builder: (_, posts, _) => Text(
            'Download ${posts.length} bookmarks'.hc,
          ),
        ),
    };
    return AppBar(
      title: Text('Bookmarks'.hc),
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
          if (itemBuilder.isNotEmpty)
            BooruPopupMenuButton(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    ref.read(bookmarkEditProvider.notifier).state = true;
                  case 'download_all':
                    ref.bookmarks.downloadBookmarks(
                      ref.readConfig,
                      controller.items.map((e) => e.bookmark).toList(),
                    );
                }
              },
              itemBuilder: itemBuilder,
            ),
      ],
    );
  }
}
