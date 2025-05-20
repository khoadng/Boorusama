// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../bulk_downloads/routes.dart';
import '../../../../configs/config.dart';
import '../../../../configs/routes.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../queries/providers.dart';
import '../../../selected_tags/selected_tag_controller.dart';
import 'selected_tag_list.dart';

class SelectedTagListWithData extends ConsumerWidget {
  const SelectedTagListWithData({
    required this.controller,
    required this.config,
    super.key,
    this.flexibleBorderPosition = true,
  });

  final SelectedTagController controller;
  final bool flexibleBorderPosition;
  final BooruConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagComposer = ref.watch(tagQueryComposerProvider(config.search));
    final colorScheme = Theme.of(context).colorScheme;
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    final borderSide = BorderSide(
      color: colorScheme.outlineVariant,
      width: 1,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: flexibleBorderPosition
            ? Border(
                bottom: searchBarPosition == SearchBarPosition.top
                    ? borderSide
                    : BorderSide.none,
                top: searchBarPosition == SearchBarPosition.bottom
                    ? borderSide
                    : BorderSide.none,
              )
            : Border(
                bottom: borderSide,
              ),
      ),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, tags, child) {
          return tags.isNotEmpty
              ? SelectedTagList(
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
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
