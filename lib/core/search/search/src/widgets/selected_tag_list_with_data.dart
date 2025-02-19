// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../bulk_downloads/routes.dart';
import '../../../../configs/ref.dart';
import '../../../../configs/routes.dart';
import '../../../queries/providers.dart';
import '../../../selected_tags/selected_tag_controller.dart';
import 'selected_tag_list.dart';

class SelectedTagListWithData extends ConsumerWidget {
  const SelectedTagListWithData({
    required this.controller,
    super.key,
  });

  final SelectedTagController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final tagComposer = ref.watch(currentTagQueryComposerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, tags, child) {
          return tags.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SelectedTagList(
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
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
