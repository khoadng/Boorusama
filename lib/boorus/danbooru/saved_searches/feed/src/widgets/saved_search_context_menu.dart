// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/bulk_downloads/routes.dart';
import '../../../../../../core/tags/tag/widgets.dart';
import '../../../saved_search/saved_search.dart';

class SavedSearchContextMenu extends ConsumerWidget
    with TagContextMenuButtonConfigMixin {
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

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          copyButton(context, tag),
          searchButton(ref, tag),
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
