// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/default_post_context_menu.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/infinite_post_list.dart';
import 'package:boorusama/common/collection_utils.dart';

class FavoriteGroupDetailsPage extends StatelessWidget {
  const FavoriteGroupDetailsPage({
    super.key,
    required this.group,
    required this.postIds,
  });

  final FavoriteGroup group;
  final Queue<int> postIds;

  @override
  Widget build(BuildContext context) {
    return InfinitePostList(
      onLoadMore: () => context.read<PostBloc>().add(PostFetched(
            tags: '',
            fetcher: FavoriteGroupPostFetcher(ids: postIds.dequeue(20)),
          )),
      // onRefresh: (controller) {
      //   _refresh(context);
      // },
      sliverHeaderBuilder: (context) => [
        SliverAppBar(
          title: Text(group.name.replaceAll('_', ' ')),
          floating: true,
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: [
            IconButton(
              onPressed: () {
                goToSearchPage(
                  context,
                  tag: group.getQueryString(),
                );
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                goToBulkDownloadPage(
                  context,
                  [group.getQueryString()],
                );
              },
              icon: const Icon(Icons.download),
            ),
          ],
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 5,
          ),
        ),
      ],
      multiSelectActions: (selectedPosts, endMultiSelect) =>
          FavoriteGroupMultiSelectionActions(
        selectedPosts: selectedPosts,
        endMultiSelect: endMultiSelect,
        onRemoveFromFavGroup: () {
          final selectedIds = selectedPosts.map((e) => e.id).toList();

          context.read<FavoriteGroupsBloc>().add(FavoriteGroupsItemRemoved(
                group: group,
                postIds: selectedIds,
                onSuccess: (_) {
                  context.read<PostBloc>().add(PostRemoved(
                        postIds: selectedIds,
                      ));
                },
              ));
        },
      ),
      contextMenuBuilder: (post, next) => FavoriteGroupsPostContextMenu(
        post: post,
        onMultiSelect: next,
        onRemoveFromFavGroup: () =>
            context.read<FavoriteGroupsBloc>().add(FavoriteGroupsItemRemoved(
                  group: group,
                  postIds: [post.post.id],
                  onSuccess: (_) {
                    context.read<PostBloc>().add(PostRemoved(
                          postIds: [post.post.id],
                        ));
                  },
                )),
      ),
    );
  }
}
