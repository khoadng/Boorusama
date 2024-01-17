// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/danbooru_post_details_page.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'danbooru_tag_context_menu.dart';

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
              itemBuilder: (context, tag) => DanbooruTagContextMenu(
                tag: tag.rawName,
                child: PostTagListChip(
                  tag: tag.rawName,
                  postCount: tag.postCount,
                  tagCategory: tag.category,
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
