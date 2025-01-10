// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../../../foundation/toast.dart';
import '../providers/global_blacklisted_tag_notifier.dart';
import '../providers/local_providers.dart';
import '../types/utils.dart';
import '../widgets/blacklisted_tag_view_scaffold.dart';
import 'blacklisted_tag_config_sheet.dart';

const kFavoriteTagsSelectedLabelKey = 'favorite_tags_selected_label';

class BlacklistedTagPage extends ConsumerWidget {
  const BlacklistedTagPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(globalBlacklistedTagsProvider);
    final sortType = ref.watch(selectedBlacklistedTagsSortTypeProvider);
    final sortedTags = sortBlacklistedTags(tags, sortType);

    return BlacklistedTagsViewScaffold(
      title: 'blacklist.manage.title'.tr(),
      actions: [
        IconButton(
          onPressed: () {
            showMaterialModalBottomSheet(
              context: context,
              settings: const RouteSettings(name: 'blacklisted_tag_sort'),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              builder: (context) => BlacklistedTagConfigSheet(
                onSorted: (value) {
                  ref
                      .read(selectedBlacklistedTagsSortTypeProvider.notifier)
                      .state = value;
                },
              ),
            );
          },
          icon: const Icon(
            Icons.sort,
            fill: 1,
            size: 20,
          ),
        ),
      ],
      tags: sortedTags.map((e) => e.name).toList(),
      onAddTag: (tag) {
        ref
            .read(globalBlacklistedTagsProvider.notifier)
            .addTagWithToast(context, tag);
      },
      onEditTap: (oldTag, newTag) {
        final oldBlacklistedTag =
            sortedTags.firstWhereOrNull((e) => e.name == oldTag);

        if (oldBlacklistedTag == null) {
          showErrorToast(context, 'Cannot find tag $oldTag');
          return;
        }

        ref.read(globalBlacklistedTagsProvider.notifier).updateTag(
              oldTag: oldBlacklistedTag,
              newTag: newTag,
            );
      },
      onRemoveTag: (tag) {
        final blacklistedTag =
            sortedTags.firstWhereOrNull((e) => e.name == tag);

        if (blacklistedTag == null) {
          showErrorToast(context, 'Cannot find tag $tag');
          return;
        }

        ref
            .read(globalBlacklistedTagsProvider.notifier)
            .removeTag(blacklistedTag);
      },
    );
  }
}
