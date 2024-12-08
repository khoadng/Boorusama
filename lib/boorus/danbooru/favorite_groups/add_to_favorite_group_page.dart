// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/images/booru_image.dart';
import 'package:boorusama/core/search/search_bar.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/toast.dart';
import '../posts/post/danbooru_post.dart';
import '../router.dart';
import 'danbooru_favorite_group.dart';
import 'favorite_groups_filterable_notifier.dart';
import 'favorite_groups_notifier.dart';

class AddToFavoriteGroupPage extends ConsumerWidget {
  const AddToFavoriteGroupPage({
    super.key,
    required this.posts,
  });

  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'favorite_groups.add_to_group_dialog_title',
          style: Theme.of(context).textTheme.titleLarge,
        ).tr(),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    final config = ref.watchConfigSearch;
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
    List<DanbooruFavoriteGroup> groups,
    BuildContext context,
    WidgetRef ref,
    BooruConfigSearch config,
  ) {
    return ImplicitlyAnimatedList<DanbooruFavoriteGroup>(
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
              group.name.replaceAll('_', ' '),
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
                        duration: AppDurations.extraLongToast,
                        content:
                            translatable ? Text(message).tr() : Text(message),
                      );
                    },
                    onSuccess: (newGroup) {
                      showSimpleSnackBar(
                        context: context,
                        duration: AppDurations.longToast,
                        content: Text(
                          'favorite_groups.items_added_notification_popup'
                              .tr()
                              .replaceAll('{0}', '${posts.length}')
                              .replaceAll(
                                '{1}',
                                group.name.replaceAll('_', ' '),
                              ),
                        ),
                      );
                      Navigator.of(context).pop(true);
                    },
                  );
            },
          ),
        );
      },
    );
  }
}
