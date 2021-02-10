// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/home/latest/latest_posts_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/search_stats.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/popular_search_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
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

final _popularSearchProvider =
    FutureProvider.autoDispose<List<SearchStats>>((ref) async {
  final repo = ref.watch(popularSearchProvider);

  final searches = await repo.getSearchStatsByDate(DateTime.now());

  ref.maintainState = true;

  return searches;
});

class LatestView extends HookWidget {
  const LatestView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final refreshController = useState(RefreshController());
    final posts = useProvider(_postProvider);
    final postsState = useProvider(_postsStateProvider);
    final scrollController = useState(AutoScrollController());

    final gridKey = useState(GlobalKey());

    final popularSearches = useProvider(_popularSearchProvider);

    useEffect(() {
      return () => scrollController.value.dispose;
    }, []);

    return postsState.maybeWhen(
      refreshing: () => CustomScrollView(
        controller: scrollController.value,
        shrinkWrap: true,
        slivers: [
          SliverAppBar(
            toolbarHeight: kToolbarHeight * 1.2,
            title: SearchBar(
              enabled: false,
              leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}
                  // scaffoldKey.currentState.openDrawer(),
                  ),
              onTap: () =>
                  AppRouter.router.navigateTo(context, "/posts/search/"),
            ),
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
          ),
          SliverPostGridPlaceHolder(),
        ],
      ),
      orElse: () => ProviderListener(
        provider: latestPostsStateNotifierProvider,
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
        child: InfiniteLoadList(
          headers: [
            SliverAppBar(
              toolbarHeight: kToolbarHeight * 1.2,
              title: SearchBar(
                enabled: false,
                leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}
                    // scaffoldKey.currentState.openDrawer(),
                    ),
                onTap: () =>
                    AppRouter.router.navigateTo(context, "/posts/search/"),
              ),
              floating: true,
              snap: true,
              automaticallyImplyLeading: false,
            ),
            SliverToBoxAdapter(
              child: popularSearches.maybeWhen(
                  data: (searches) => Tags(
                        horizontalScroll: true,
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        itemCount: searches.length,
                        itemBuilder: (index) {
                          return Chip(
                              padding: EdgeInsets.all(4.0),
                              labelPadding: EdgeInsets.all(1.0),
                              visualDensity: VisualDensity.compact,
                              label: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.85),
                                child: Text(
                                  searches[index].keyword.pretty,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ));
                        },
                      ),
                  orElse: () => SizedBox.shrink()),
            ),
          ],
          onRefresh: () =>
              context.read(latestPostsStateNotifierProvider).refresh(),
          onLoadMore: () =>
              context.read(latestPostsStateNotifierProvider).getMorePosts(),
          onItemChanged: (index) {
            if (index > posts.length * 0.8) {
              context.read(latestPostsStateNotifierProvider).getMorePosts();
            }
          },
          scrollController: scrollController.value,
          gridKey: gridKey.value,
          posts: posts,
          refreshController: refreshController.value,
        ),
      ),
    );
  }
}
