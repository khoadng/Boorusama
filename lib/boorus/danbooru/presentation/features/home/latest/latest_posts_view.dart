// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/search_stats.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/tags/popular_search_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/infinite_load_list.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

final _postProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final repo = ref.watch(postProvider);
  final page = ref.watch(_pageProvider);

  final posts = await repo.getPosts("", page.state, limit: 20);

  ref.maintainState = true;

  return posts;
});

final _pageProvider = StateProvider.autoDispose<int>((ref) {
  return 1;
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
    final posts = useState(<Post>[]);
    final scrollController = useState(AutoScrollController());
    final page = useProvider(_pageProvider);
    final postsAtPage = useProvider(_postProvider);

    final gridKey = useState(GlobalKey());

    final popularSearches = useProvider(_popularSearchProvider);
    final isRefreshing = useState(true);

    useEffect(() {
      return () => scrollController.value.dispose;
    }, []);

    void refresh() {
      isRefreshing.value = true;
      page.state = 1;
    }

    void loadMore() {
      page.state = page.state + 1;
    }

    void loadMoreIfNeeded(int index) {
      if (index > posts.value.length * 0.8) {
        page.state = page.state + 1;
      }
    }

    useEffect(() {
      postsAtPage.whenData((data) {
        if (page.state > 1) {
          // Dedupe
          data
            ..removeWhere((post) {
              final p = posts.value.firstWhere(
                (sPost) => sPost.id == post.id,
                orElse: () => null,
              );
              return p?.id == post.id;
            });
        }

        if (isRefreshing.value) {
          isRefreshing.value = false;
          posts.value = data;
        } else {
          // in Loading mode
          refreshController.value.loadComplete();
          posts.value = [...posts.value, ...data];
        }

        if (data.isEmpty) {
          refreshController.value.loadNoData();
        }
      });

      return null;
    }, [postsAtPage]);

    return isRefreshing.value
        ? CustomScrollView(
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
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Center(child: CircularProgressIndicator()),
              )),
              SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  sliver: SliverPostGridPlaceHolder()),
            ],
          )
        : InfiniteLoadList(
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ));
                          },
                        ),
                    orElse: () => SizedBox.shrink()),
              ),
            ],
            onRefresh: () => refresh(),
            onLoadMore: () => loadMore(),
            onItemChanged: (index) => loadMoreIfNeeded(index),
            scrollController: scrollController.value,
            gridKey: gridKey.value,
            posts: posts.value,
            refreshController: refreshController.value,
          );
  }
}
