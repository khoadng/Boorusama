// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
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
    final config = ref.watchConfig;
    final tagDetails =
        allowFetch ? ref.watch(danbooruTagListProvider(config))[post.id] : null;
    final count = tagDetails?.allTags.length ?? post.tags.length;
    final isExpanded =
        ref.watch(danbooruTagTileExpansionStateProvider(initialExpanded));

    return Theme(
      data: context.theme.copyWith(
        listTileTheme: context.theme.listTileTheme.copyWith(
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
                  backgroundColor: context.colorScheme.surfaceVariant,
                ),
                onPressed: () => ref.danbooruEdit(post),
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
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: PostTagList(
                tags: ref.watch(danbooruTagGroupsProvider(post)).maybeWhen(
                      data: (data) => data,
                      orElse: () => null,
                    ),
                itemBuilder: (context, tag) => GeneralTagContextMenu(
                  tag: tag.rawName,
                  itemBindings: {
                    'post.detail.open_wiki'.tr(): () => launchWikiPage(
                          config.url,
                          tag.rawName,
                        ),
                    if (config.hasLoginDetails())
                      'post.detail.add_to_blacklist'.tr(): () => ref
                          .read(
                              danbooruBlacklistedTagsProvider(config).notifier)
                          .addWithToast(tag: tag.rawName),
                    if (config.hasLoginDetails())
                      'post.detail.copy_and_open_saved_search'.tr(): () {
                        Clipboard.setData(
                          ClipboardData(text: tag.rawName),
                        ).then((value) => goToSavedSearchEditPage(context));
                      },
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
