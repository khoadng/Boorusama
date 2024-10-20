// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';

class SelectedTagListWithData extends ConsumerWidget {
  const SelectedTagListWithData({
    super.key,
    required this.controller,
  });

  final SelectedTagController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final tagComposer = ref.watch(tagQueryComposerProvider(config));

    return ColoredBox(
        color: context.colorScheme.surface,
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
        ));
  }
}
