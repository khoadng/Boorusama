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
    required this.tags,
  });

  final List<TagSearchItem> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          SelectedTagList(
            tags: tags,
            onClear: () => ref.read(selectedTagsProvider.notifier).clear(),
            onDelete: (tag) =>
                ref.read(searchProvider.notifier).removeSelectedTag(tag),
            onBulkDownload: (tags) => goToBulkDownloadPage(
              context,
              tags.map((e) => e.toString()).toList(),
              ref: ref,
            ),
          ),
          if (tags.isNotEmpty) const Divider(height: 15, thickness: 1),
        ],
      ),
    );
  }
}
