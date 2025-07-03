// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../../core/search/search/routes.dart';
import '../../../../../../core/tags/tag/providers.dart';
import '../../../../../../core/tags/tag/routes.dart';
import '../../../../../../core/tags/tag/tag.dart';
import '../../../../../../core/tags/tag/widgets.dart';
import '../../../../tags/_shared/tag_list_notifier.dart';
import '../../../../tags/tag/widgets.dart';
import '../../../listing/providers.dart';
import '../../../post/post.dart';

final danbooruTagTileExpansionStateProvider =
    StateProvider.autoDispose.family<bool, bool>((ref, value) {
  return value;
});

class DanbooruTagsTile extends ConsumerWidget {
  const DanbooruTagsTile({
    required this.post,
    super.key,
    this.allowFetch = true,
    this.initialExpanded = false,
  });

  final DanbooruPost post;
  final bool allowFetch;
  final bool initialExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final tagDetails =
        allowFetch ? ref.watch(danbooruTagListProvider(config))[post.id] : null;
    final count = tagDetails?.allTags.length ?? post.tags.length;
    final isExpanded =
        ref.watch(danbooruTagTileExpansionStateProvider(initialExpanded));

    return RawTagsTile(
      title: RawTagsTileTitle(
        post: post,
        count: count,
        itemBuilder: {
          if (config.hasLoginDetails()) 'edit': const Text('Edit'),
        },
        onMultiSelect: () {
          goToShowTaglistPage(
            ref,
            post,
            initiallyMultiSelectEnabled: true,
          );
        },
        onSelected: (value) {
          if (value == 'edit') {
            ref.danbooruEdit(post);
          }
        },
      ),
      initiallyExpanded: initialExpanded,
      onExpansionChanged: (value) {
        ref
            .read(
              danbooruTagTileExpansionStateProvider(initialExpanded).notifier,
            )
            .state = value;
      },
      children: [
        if (isExpanded)
          PostTagList(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            tags: ref.watch(tagGroupsProvider((config, post))).maybeWhen(
                  data: (data) => data,
                  orElse: () => null,
                ),
            itemBuilder: (context, tag) => DanbooruTagContextMenu(
              tag: tag.rawName,
              child: PostTagListChip(
                tag: tag,
                auth: config,
                onTap: () => goToSearchPage(ref, tag: tag.rawName),
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
