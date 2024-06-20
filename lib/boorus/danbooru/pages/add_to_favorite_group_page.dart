// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/time.dart';

class AddToFavoriteGroupPage extends ConsumerWidget {
  const AddToFavoriteGroupPage({
    super.key,
    required this.posts,
  });

  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'favorite_groups.add_to_group_dialog_title',
          style: context.textTheme.titleLarge,
        ).tr(),
      ),
      backgroundColor: context.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: BooruImage(
                    imageUrl: posts[index].url720x720,
                    aspectRatio: posts[index].aspectRatio,
                  ),
                ),
                itemCount: posts.length,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListTile(
              visualDensity: VisualDensity.compact,
              title: Text(
                'favorite_groups.add_to'.tr().toUpperCase(),
                style: context.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              trailing: FilledButton(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => goToFavoriteGroupCreatePage(
                  context,
                  enableManualPostInput: false,
                ),
                child: const Text('favorite_groups.create').tr(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: BooruSearchBar(
              onChanged: (value) => ref
                  .read(
                      danbooruFavoriteGroupFilterableProvider(config).notifier)
                  .filter(value),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _FavoriteGroupList(posts: posts)),
        ],
      ),
    );
  }
}

class _FavoriteGroupList extends ConsumerWidget {
  const _FavoriteGroupList({
    required this.posts,
  });

  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final filteredGroups =
        ref.watch(danbooruFavoriteGroupFilterableProvider(config));

    return filteredGroups.toOption().fold(
          () => const Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
          (groups) => groups.isEmpty
              ? const Center(child: Text('Empty'))
              : _buildList(groups, context, ref, config),
        );
  }

  Widget _buildList(
    List<FavoriteGroup> groups,
    BuildContext context,
    WidgetRef ref,
    BooruConfig config,
  ) {
    return ImplicitlyAnimatedList<FavoriteGroup>(
      items: groups,
      controller: ModalScrollController.of(context),
      areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
      insertDuration: const Duration(milliseconds: 250),
      removeDuration: const Duration(milliseconds: 250),
      itemBuilder: (_, animation, group, index) {
        return SizeFadeTransition(
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: animation,
          child: ListTile(
            title: Text(
              group.name.replaceUnderscoreWithSpace(),
            ),
            subtitle: Text(group.updatedAt
                .fuzzify(locale: Localizations.localeOf(context))),
            trailing: Text('favorite_groups.group_item_counter'.plural(
              group.postIds.length,
            )),
            onTap: () {
              ref
                  .read(danbooruFavoriteGroupsProvider(config).notifier)
                  .addToGroup(
                    group: group,
                    postIds: posts.map((e) => e.id).toList(),
                    onFailure: (message, translatable) {
                      showSimpleSnackBar(
                        context: context,
                        duration: const Duration(seconds: 6),
                        content:
                            translatable ? Text(message).tr() : Text(message),
                      );
                    },
                    onSuccess: (newGroup) {
                      showSimpleSnackBar(
                        context: context,
                        duration: const Duration(seconds: 3),
                        content: Text(
                          'favorite_groups.items_added_notification_popup'
                              .tr()
                              .replaceAll('{0}', '${posts.length}')
                              .replaceAll(
                                '{1}',
                                group.name.replaceUnderscoreWithSpace(),
                              ),
                        ),
                      );
                      context.navigator.pop(true);
                    },
                  );
            },
          ),
        );
      },
    );
  }
}
