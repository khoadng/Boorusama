// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/flutter.dart';

class SelectedTagListWithData extends ConsumerWidget {
  const SelectedTagListWithData({
    super.key,
    required this.controller,
    required this.searchController,
  });

  final SelectedTagController controller;
  final SearchPageController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        color: context.theme.scaffoldBackgroundColor,
        child: ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, tags, child) {
            return Column(
              children: [
                SelectedTagList(
                  tags: tags,
                  onClear: () => controller.clear(),
                  onDelete: (tag) {
                    controller.removeTag(tag);
                    searchController.resetToOptions();
                  },
                  onBulkDownload: (tags) => goToBulkDownloadPage(
                    context,
                    tags.map((e) => e.toString()).toList(),
                    ref: ref,
                  ),
                ),
                if (tags.isNotEmpty) const Divider(height: 15, thickness: 1),
              ],
            );
          },
        ));
  }
}
