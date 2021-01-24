import 'package:boorusama/boorus/danbooru/application/home/latest/latest_posts_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../shared/sliver_post_grid_placeholder.dart';

class LatestView extends HookWidget {
  const LatestView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final refreshController =
        useState(RefreshController(initialRefresh: false));
    final scrollController = useScrollController();
    final gridKey = useState(GlobalKey());
    final latestPosts = useProvider(latestPostsProvider);
    final isRefreshing = useProvider(isRefreshingProvider);
    final isLoadingMore = useProvider(isLoadingMoreProvider);

    if (!isLoadingMore) {
      refreshController.value.loadComplete();
    }

    if (!isRefreshing) {
      refreshController.value.refreshCompleted();
    }

    return SafeArea(
      top: false,
      bottom: false,
      child: SmartRefresher(
        controller: refreshController.value,
        enablePullUp: true,
        enablePullDown: true,
        header: const MaterialClassicHeader(),
        footer: const ClassicFooter(),
        onRefresh: () =>
            context.read(latestPostsStateNotifierProvider).refresh(),
        onLoading: () =>
            context.read(latestPostsStateNotifierProvider).getMore(),
        child: CustomScrollView(
          key: PageStorageKey<String>("latest"),
          slivers: <Widget>[
            SliverOverlapInjector(
              // This is the flip side of the SliverOverlapAbsorber
              // above.
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverPadding(
              padding: EdgeInsets.all(6.0),
              sliver: isRefreshing
                  ? SliverPostGridPlaceHolder(
                      scrollController: scrollController)
                  : SliverPostGrid(
                      key: gridKey.value,
                      posts: latestPosts,
                      scrollController: scrollController,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
