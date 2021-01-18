import 'package:boorusama/application/home/latest/latest_posts_state_notifier.dart';
import 'package:boorusama/presentation/shared/sliver_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../sliver_post_grid_placeholder.dart';

class LatestView extends HookWidget {
  const LatestView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final refreshController =
        useState(RefreshController(initialRefresh: false));
    final gridKey = useState(GlobalKey());
    useEffect(() {
      Future.microtask(
          () => context.read(latestPostsStateNotifierProvider).refresh());
      return () => {};
    }, []);
    final latestPosts = useProvider(latestPostsProvider);
    final isRefreshing = useProvider(isRefreshingProvider);
    final isLoadingMore = useProvider(isLoadingMoreProvider);

    if (!isLoadingMore) {
      refreshController.value.loadComplete();
    }

    if (!isRefreshing) {
      refreshController.value.refreshCompleted();
    }

    return Scaffold(
      body: SmartRefresher(
        controller: refreshController.value,
        enablePullUp: true,
        enablePullDown: true,
        header: const WaterDropMaterialHeader(),
        footer: const ClassicFooter(),
        onRefresh: () =>
            context.read(latestPostsStateNotifierProvider).refresh(),
        onLoading: () =>
            context.read(latestPostsStateNotifierProvider).getMore(),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: EdgeInsets.all(2.0),
                  ),
                ],
              ),
            ),
            isRefreshing
                ? SliverPostGridPlaceHolder()
                : SliverPostGrid(
                    key: gridKey.value,
                    posts: latestPosts,
                  ),
          ],
        ),
      ),
    );
  }
}
