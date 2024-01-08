// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/pages/danbooru_post_details_page.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class DanbooruTagsTile extends ConsumerWidget {
  const DanbooruTagsTile({
    super.key,
    required this.post,
    this.allowFetch = true,
  });

  final DanbooruPost post;
  final bool allowFetch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final tagItems = allowFetch
        ? ref.watch(danbooruTagGroupsProvider(post))
        : const AsyncData(<TagGroupItem>[]);
    final tagDetails =
        allowFetch ? ref.watch(danbooruTagListProvider(config))[post.id] : null;
    final count = tagDetails?.allTags.length ?? post.tags.length;

    return Theme(
      data: context.theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Row(
          children: [
            Text('$count tags'),
            if (config.hasLoginDetails())
              FilledButton(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  shape: const CircleBorder(),
                  backgroundColor: context.colorScheme.surfaceVariant,
                ),
                onPressed: tagItems.maybeWhen(
                  data: (data) => () => goToTagEdiPage(
                        context,
                        post: post,
                        tags: data
                            .map((e) => e.tags.map((e) => e.rawName))
                            .expand((e) => e)
                            .toList(),
                        rating: tagDetails != null
                            ? tagDetails.rating
                            : post.rating,
                      ),
                  orElse: () => null,
                ),
                child: Icon(
                  Symbols.edit,
                  size: 16,
                  color: context.colorScheme.onSurfaceVariant,
                  fill: 1,
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PostTagList(
              tags: tagItems.maybeWhen(
                data: (data) => data,
                orElse: () => null,
              ),
              itemBuilder: (context, tag) => ContextMenu(
                items: [
                  const PopupMenuItem(
                    value: 'copy',
                    child: Text('Copy tag'),
                  ),
                  PopupMenuItem(
                    value: 'wiki',
                    child: const Text('post.detail.open_wiki').tr(),
                  ),
                  PopupMenuItem(
                    value: 'add_to_favorites',
                    child: const Text('post.detail.add_to_favorites').tr(),
                  ),
                  if (config.hasLoginDetails())
                    PopupMenuItem(
                      value: 'blacklist',
                      child: const Text('post.detail.add_to_blacklist').tr(),
                    ),
                  if (config.hasLoginDetails())
                    PopupMenuItem(
                      value: 'copy_and_move_to_saved_search',
                      child: const Text(
                        'post.detail.copy_and_open_saved_search',
                      ).tr(),
                    ),
                ],
                onSelected: (value) {
                  if (value == 'blacklist') {
                    ref
                        .read(danbooruBlacklistedTagsProvider(config).notifier)
                        .addWithToast(tag: tag.rawName);
                  } else if (value == 'wiki') {
                    launchWikiPage(config.url, tag.rawName);
                  } else if (value == 'copy_and_move_to_saved_search') {
                    Clipboard.setData(
                      ClipboardData(text: tag.rawName),
                    ).then((value) => goToSavedSearchEditPage(context));
                  } else if (value == 'add_to_favorites') {
                    ref.read(favoriteTagsProvider.notifier).add(tag.rawName);
                  } else if (value == 'copy') {
                    Clipboard.setData(
                      ClipboardData(text: tag.rawName),
                    ).then((value) => showSuccessToast('Copied'));
                  }
                },
                child: PostTagListChip(
                  tag: tag,
                  onTap: () => goToSearchPage(context, tag: tag.rawName),
                  maxTagWidth: null,
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
