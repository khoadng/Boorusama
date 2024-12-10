// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/listing/providers.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/tags/tag/tag.dart';
import 'package:boorusama/core/tags/tag/widgets.dart';
import 'package:boorusama/router.dart';
import '../../../../tags/_shared/tag_list_notifier.dart';
import '../../../../tags/tag/widgets.dart';
import '../../../post/post.dart';
import '../local_providers.dart';

final danbooruTagTileExpansionStateProvider =
    StateProvider.autoDispose.family<bool, bool>((ref, value) {
  return value;
});

class DanbooruTagsTile extends ConsumerWidget {
  const DanbooruTagsTile({
    super.key,
    required this.post,
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

    return Theme(
      data: Theme.of(context).copyWith(
        listTileTheme: Theme.of(context).listTileTheme.copyWith(
              visualDensity: VisualDensity.compact,
            ),
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: initialExpanded,
        onExpansionChanged: (value) {
          ref
              .read(danbooruTagTileExpansionStateProvider(initialExpanded)
                  .notifier)
              .state = value;
        },
        title: Row(
          children: [
            Text('$count tags'),
            if (config.hasLoginDetails())
              FilledButton(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  shape: const CircleBorder(),
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                onPressed: () => ref.danbooruEdit(post),
                child: Icon(
                  Symbols.edit,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fill: 1,
                ),
              ),
          ],
        ),
        children: [
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: PostTagList(
                tags: ref.watch(danbooruTagGroupsProvider(post)).maybeWhen(
                      data: (data) => data,
                      orElse: () => null,
                    ),
                itemBuilder: (context, tag) => DanbooruTagContextMenu(
                  tag: tag.rawName,
                  child: PostTagListChip(
                    tag: tag,
                    onTap: () => goToSearchPage(context, tag: tag.rawName),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
