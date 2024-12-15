// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/downloads/routes.dart';
import '../../../../../../core/tags/tag/widgets.dart';
import '../../../saved_search/saved_search.dart';

class SavedSearchContextMenu extends ConsumerWidget
    with TagContextMenuButtonConfigMixin {
  const SavedSearchContextMenu({
    super.key,
    required this.search,
    required this.child,
  });

  final SavedSearch search;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = search.toQuery();

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          copyButton(context, tag),
          searchButton(context, tag),
          ContextMenuButtonConfig(
            'download.bulk_download'.tr(),
            onPressed: () {
              goToBulkDownloadPage(context, [tag], ref: ref);
            },
          ),
        ],
      ),
      child: child,
    );
  }
}
