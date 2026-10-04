// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../../../core/bulk_downloads/routes.dart';
import '../../../../../../core/tags/tag/widgets.dart';
import '../../../saved_search/types.dart';

class SavedSearchContextMenu extends ConsumerWidget
    with TagContextMenuItemsMixin {
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

    return KurumiContextMenu(
      menuItemsBuilder: (_) => [
        copyButton(context, tag),
        searchButton(ref, tag),
        KurumiContextMenuTile(
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
