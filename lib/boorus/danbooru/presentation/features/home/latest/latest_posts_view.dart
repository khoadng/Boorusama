// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/home/latest/latest_posts_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/list_item_status.dart';

final _posts = Provider<List<Post>>(
    (ref) => ref.watch(latestPostsStateNotifierProvider.state).posts.items);
final _postProvider = Provider<List<Post>>((ref) {
  return ref.watch(_posts);
});

final _postsState = Provider<ListItemStatus<Post>>((ref) {
  return ref.watch(latestPostsStateNotifierProvider.state).posts.status;
});
final _postsStateProvider = Provider<ListItemStatus<Post>>((ref) {
  return ref.watch(_postsState);
});

class LatestView extends HookWidget {
  const LatestView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final refreshController =
        useState(RefreshController(initialRefresh: false));
    final scrollController = useScrollController();
    final gridKey = useState(GlobalKey());

    final posts = useProvider(_postProvider);
    final postsState = useProvider(_postsStateProvider);

    return ProviderListener<ListItemStatus<Post>>(
      provider: _postsStateProvider,
      onChange: (context, state) {
        state.maybeWhen(
          fetched: () {
            refreshController.value.loadComplete();
            refreshController.value.refreshCompleted();
          },
          error: () => Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text("Something went wrong"))),
          orElse: () {},
        );
      },
      child: SmartRefresher(
        controller: refreshController.value,
        enablePullUp: true,
        enablePullDown: true,
        header: const MaterialClassicHeader(),
        footer: const ClassicFooter(),
        onRefresh: () =>
            context.read(latestPostsStateNotifierProvider).refresh(),
        onLoading: () =>
            context.read(latestPostsStateNotifierProvider).getMorePosts(),
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.all(6.0),
              sliver: postsState.maybeWhen(
                refreshing: () => SliverPostGridPlaceHolder(
                    scrollController: scrollController),
                orElse: () => SliverPostGrid(
                  onTap: (post, index) {
                    context
                        .read(latestPostsStateNotifierProvider)
                        .viewPost(post);
                    AppRouter.router.navigateTo(
                      context,
                      "/posts/latest",
                      routeSettings: RouteSettings(arguments: [
                        post,
                        "${gridKey.toString()}_${post.id}",
                        index,
                      ]),
                    );
                  },
                  key: gridKey.value,
                  posts: posts,
                  scrollController: scrollController,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
