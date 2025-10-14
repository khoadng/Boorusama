// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../router.dart';
import '../../../search/search/widgets.dart';
import '../../../search/selected_tags/types.dart';

void goToBlacklistedTagsSearchPage(
  BuildContext context, {
  required void Function(List<String> tags, String currentQuery) onSelectDone,
  List<String>? initialTags,
}) {
  showDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: RouterPageConstant.blacklistedSearch,
    ),
    builder: (c) {
      return SelectedTagEditDialog(
        tag: TagSearchItem.raw(tag: initialTags?.join(' ') ?? ''),
        onUpdated: (tag) {
          if (tag.isNotEmpty) {
            onSelectDone([], tag.trim());
          }
        },
      );
    },
  );
}
