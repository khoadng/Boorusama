// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/infinite_post_list.dart';

class FavoriteGroupDetailsPage extends StatelessWidget {
  const FavoriteGroupDetailsPage({
    super.key,
    required this.favoriteGroupId,
    required this.groupName,
  });

  final int favoriteGroupId;
  final String groupName;

  @override
  Widget build(BuildContext context) {
    return InfinitePostList(
      onLoadMore: () => context.read<PostBloc>().add(PostFetched(
            tags: 'favgroup:$favoriteGroupId',
            fetcher: SearchedPostFetcher.fromTags('favgroup:$favoriteGroupId'),
          )),
      onRefresh: (controller) {
        context.read<PostBloc>().add(PostRefreshed(
              tag: 'favgroup:$favoriteGroupId',
              fetcher:
                  SearchedPostFetcher.fromTags('favgroup:$favoriteGroupId'),
            ));
      },
      sliverHeaderBuilder: (context) => [
        SliverAppBar(
          title: Text(groupName.replaceAll('_', ' ')),
          floating: true,
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 5,
          ),
        ),
      ],
    );
  }
}
