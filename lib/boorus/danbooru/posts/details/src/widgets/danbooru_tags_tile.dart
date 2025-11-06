// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../../core/search/search/routes.dart';
import '../../../../../../core/tags/tag/providers.dart';
import '../../../../../../core/tags/tag/types.dart';
import '../../../../../../core/tags/tag/widgets.dart';
import '../../../../../../core/widgets/booru_popup_menu_button.dart';
import '../../../../configs/providers.dart';
import '../../../../tags/_shared/tag_list_notifier.dart';
import '../../../../tags/tag/widgets.dart';
import '../../../listing/providers.dart';
import '../../../post/types.dart';

final danbooruTagTileExpansionStateProvider = StateProvider.autoDispose
    .family<bool, bool>((ref, value) {
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
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));
    final tagDetails = allowFetch
        ? ref.watch(danbooruTagListProvider(config))[post.id]
        : null;
    final count = tagDetails?.allTags.length ?? post.tags.length;
    final isExpanded = ref.watch(
      danbooruTagTileExpansionStateProvider(initialExpanded),
    );

    return RawTagsTile(
      title: RawTagsTileTitle(
        auth: config,
        post: post,
        count: count,
        menuItems: loginDetails.hasLogin()
            ? [
                BooruPopupMenuItem(
                  title: Text(context.t.generic.action.edit),
                  onTap: () => ref.danbooruEdit(post),
                ),
              ]
            : null,
      ),
      initiallyExpanded: initialExpanded,
      onExpansionChanged: (value) {
        ref
                .read(
                  danbooruTagTileExpansionStateProvider(
                    initialExpanded,
                  ).notifier,
                )
                .state =
            value;
      },
      children: [
        if (isExpanded)
          PostTagList(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            tags: ref
                .watch(tagGroupsProvider((config, post)))
                .maybeWhen(
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
