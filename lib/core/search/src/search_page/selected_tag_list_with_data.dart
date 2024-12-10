// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../router.dart';
import '../../../configs/ref.dart';
import '../queries/providers.dart';
import '../selected_tags/selected_tag_controller.dart';
import 'widgets/selected_tag_list.dart';

class SelectedTagListWithData extends ConsumerWidget {
  const SelectedTagListWithData({
    super.key,
    required this.controller,
  });

  final SelectedTagController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final tagComposer = ref.watch(currentTagQueryComposerProvider);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, tags, child) {
          return Column(
            children: [
              SelectedTagList(
                extraTagsCount: tagComposer.compose([]).length,
                onOtherTagsCountTap: () {
                  goToUpdateBooruConfigPage(
                    context,
                    config: config,
                    initialTab: 'search',
                  );
                },
                tags: tags,
                onClear: () {
                  controller.clear();
                },
                onDelete: (tag) {
                  controller.removeTag(tag);
                },
                onUpdate: (oldTag, newTag) {
                  controller.updateTag(oldTag, newTag);
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
      ),
    );
  }
}
