// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorites_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/post_state.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

final _posts = Provider<List<Post>>(
    (ref) => ref.watch(favoritesStateNotifierProvider.state).posts);
final _postProvider = Provider<List<Post>>((ref) {
  return ref.watch(_posts);
});

final _postsState = Provider<PostState>((ref) {
  return ref.watch(favoritesStateNotifierProvider.state).postsState;
});
final _postsStateProvider = Provider<PostState>((ref) {
  return ref.watch(_postsState);
});

class FavoritesPage extends HookWidget {
  const FavoritesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final refreshController =
        useState(RefreshController(initialRefresh: false));
    final scrollController = useScrollController();
    final gridKey = useState(GlobalKey());

    final posts = useProvider(_postProvider);
    final postsState = useProvider(_postsStateProvider);

    return ProviderListener<PostState>(
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
      child: SafeArea(
        child: SmartRefresher(
          controller: refreshController.value,
          enablePullUp: true,
          enablePullDown: true,
          header: const MaterialClassicHeader(),
          footer: const ClassicFooter(),
          onRefresh: () =>
              context.read(favoritesStateNotifierProvider).refresh(),
          onLoading: () =>
              context.read(favoritesStateNotifierProvider).getMorePosts(),
          child: CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.all(6.0),
                sliver: postsState.maybeWhen(
                  fetched: () => SliverPostGrid(
                    onTap: (post, index) => AppRouter.router.navigateTo(
                      context,
                      "/posts",
                      routeSettings: RouteSettings(arguments: [
                        post,
                        "${gridKey.toString()}_${post.id}",
                        index,
                      ]),
                    ),
                    key: gridKey.value,
                    posts: posts,
                    scrollController: scrollController,
                  ),
                  orElse: () => SliverPostGridPlaceHolder(
                      scrollController: scrollController),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
