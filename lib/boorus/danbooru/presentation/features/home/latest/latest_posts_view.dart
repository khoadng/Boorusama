// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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

final _lastViewedPostIndex = Provider<int>((ref) {
  return ref
      .watch(latestPostsStateNotifierProvider.state)
      .posts
      .lastViewedItemIndex;
});
final _lastViewedPostIndexProvider = Provider<int>((ref) {
  final lastViewedPost = ref.watch(_lastViewedPostIndex);
  return lastViewedPost;
});

class LatestView extends HookWidget {
  const LatestView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final refreshController =
        useState(RefreshController(initialRefresh: false));
    final gridKey = useState(GlobalKey());

    final posts = useProvider(_postProvider);
    final postsState = useProvider(_postsStateProvider);
    final lastViewedPostIndex = useProvider(_lastViewedPostIndexProvider);
    final scrollController = useState(AutoScrollController());

    useEffect(() {
      return () => scrollController.value.dispose;
    }, []);

    useEffect(() {
      scrollController.value.scrollToIndex(lastViewedPostIndex);
      return () => null;
    }, [lastViewedPostIndex]);

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
          controller: scrollController.value,
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.all(6.0),
              sliver: postsState.maybeWhen(
                refreshing: () => SliverPostGridPlaceHolder(
                    scrollController: scrollController.value),
                orElse: () => SliverPostGrid(
                  onTap: (post, index) {
                    context
                        .read(latestPostsStateNotifierProvider)
                        .viewPost(post);
                    AppRouter.router.navigateTo(
                      context,
                      "/posts",
                      routeSettings: RouteSettings(arguments: [
                        post,
                        "${gridKey.toString()}_${post.id}",
                        index,
                        posts,
                        () {
                          context
                              .read(latestPostsStateNotifierProvider)
                              .stopViewing();
                        },
                        (index) {
                          context
                              .read(latestPostsStateNotifierProvider)
                              .viewPost(posts[index]);

                          if (index > posts.length * 0.8) {
                            context
                                .read(latestPostsStateNotifierProvider)
                                .getMorePosts();
                          }
                        }
                      ]),
                    );
                  },
                  key: gridKey.value,
                  posts: posts,
                  scrollController: scrollController.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
