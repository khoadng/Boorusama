// Flutter imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/default_post_context_menu.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/infinite_post_list.dart';

class FavoriteGroupDetailsPage extends StatelessWidget {
  const FavoriteGroupDetailsPage({
    super.key,
    required this.group,
  });

  final FavoriteGroup group;

  @override
  Widget build(BuildContext context) {
    return InfinitePostList(
      onLoadMore: () => context.read<PostBloc>().add(PostFetched(
            tags: 'favgroup:${group.id}',
            fetcher: SearchedPostFetcher.fromTags('favgroup:${group.id}'),
          )),
      onRefresh: (controller) {
        _refresh(context);
      },
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
                  tag: 'favgroup:${group.id}',
                );
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                goToBulkDownloadPage(
                  context,
                  ['favgroup:${group.id}'],
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
        onRemoveFromFavGroup: () =>
            context.read<FavoriteGroupsBloc>().add(FavoriteGroupsItemRemoved(
                  group: group,
                  postIds: selectedPosts.map((e) => e.id).toList(),
                  onSuccess: () => _refresh(context),
                )),
      ),
      contextMenuBuilder: (post, next) => FavoriteGroupsPostContextMenu(
        post: post,
        onMultiSelect: next,
        onRemoveFromFavGroup: () =>
            context.read<FavoriteGroupsBloc>().add(FavoriteGroupsItemRemoved(
                  group: group,
                  postIds: [post.post.id],
                  onSuccess: () => _refresh(context),
                )),
      ),
    );
  }

  void _refresh(BuildContext context) {
    context.read<FavoriteGroupsBloc>().add(const FavoriteGroupsRefreshed());
    context.read<PostBloc>().add(PostRefreshed(
          tag: 'favgroup:${group.id}',
          fetcher: SearchedPostFetcher.fromTags('favgroup:${group.id}'),
        ));
  }
}
