// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class SelectedTagListWithData extends ConsumerWidget {
  const SelectedTagListWithData({
    super.key,
    required this.controller,
    this.onDeleted,
    this.onClear,
  });

  final SelectedTagController controller;
  final void Function(TagSearchItem value)? onDeleted;
  final void Function()? onClear;

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
                  onClear: () {
                    controller.clear();
                    onClear?.call();
                  },
                  onDelete: (tag) {
                    controller.removeTag(tag);
                    onDeleted?.call(tag);
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
