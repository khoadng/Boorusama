// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/bulk_downloads/routes.dart';
import '../../../../../../core/tags/tag/widgets.dart';
import '../../../../../../core/widgets/booru_context_menu.dart';
import '../../../../../../core/widgets/context_menu_tile.dart';
import '../../../saved_search/types.dart';

class SavedSearchContextMenu extends ConsumerWidget {
  const SavedSearchContextMenu({
    required this.search,
    required this.child,
    super.key,
  });

  final SavedSearch search;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = search.toQuery();

    return BooruContextMenu(
      menuItemsBuilder: (context) => [
        CopyTagContextMenuTile(tag: tag),
        SearchTagContextMenuTile(tag: tag),
        ContextMenuTile(
          title: context.t.download.download,
          onTap: () {
            goToBulkDownloadPage(context, [tag], ref: ref);
          },
        ),
      ],
      child: child,
    );
  }
}
