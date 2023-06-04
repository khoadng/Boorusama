// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/search/search.dart';
import 'package:boorusama/boorus/core/ui/search/selected_tag_list.dart';

class SelectedTagListWithData extends ConsumerWidget {
  const SelectedTagListWithData({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(selectedTagsProvider);

    return SelectedTagList(
      tags: tags,
      onClear: () => ref.read(selectedTagsProvider.notifier).clear(),
      onDelete: (tag) =>
          ref.read(searchProvider.notifier).removeSelectedTag(tag),
      onBulkDownload: (tags) => goToBulkDownloadPage(
        context,
        tags.map((e) => e.toString()).toList(),
        ref: ref,
      ),
    );
  }
}
