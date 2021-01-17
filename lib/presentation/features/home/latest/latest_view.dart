import 'package:boorusama/application/home/latest/latest_state_notifier.dart';
import 'package:boorusama/domain/posts/posts.dart';
import 'package:boorusama/presentation/shared/sliver_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../sliver_post_grid_placeholder.dart';

final latestStateNotifier = StateNotifierProvider<LatestStateNotifier>(
    (ref) => LatestStateNotifier(ref));

class LatestView extends HookWidget {
  const LatestView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentPosts = useState(<Post>[]);
    final page = useState(1);
    final refreshController =
        useState(RefreshController(initialRefresh: false));
    final latestState = useProvider(latestStateNotifier.state);

    useEffect(() {
      Future.microtask(() => context.read(latestStateNotifier).refresh());
      return () => {};
    }, []);

    return ProviderListener<LatestState>(
      provider: latestStateNotifier.state,
      onChange: (context, state) {
        state.maybeWhen(
            fetched: (posts) {
              if (posts.isEmpty) {
                refreshController.value.loadNoData();
              } else {
                refreshController.value.loadComplete();
                refreshController.value.refreshCompleted();
                currentPosts.value.addAll(posts);
              }
            },
            orElse: () {});
      },
      child: latestState.when(
        initial: () => _buildLoading(),
        loading: () =>
            _buildGrid(refreshController, currentPosts, context, page),
        fetched: (_) =>
            _buildGrid(refreshController, currentPosts, context, page),
      ),
    );
  }

  Widget _buildGrid(
      ValueNotifier<RefreshController> refreshController,
      ValueNotifier<List<Post>> currentPosts,
      BuildContext context,
      ValueNotifier<int> page) {
    final gridKey = useState(GlobalKey());

    return Scaffold(
      body: SmartRefresher(
        controller: refreshController.value,
        enablePullUp: true,
        enablePullDown: true,
        header: const WaterDropMaterialHeader(),
        footer: const ClassicFooter(),
        onRefresh: () {
          currentPosts.value.clear();
          context.read(latestStateNotifier).refresh();
        },
        onLoading: () {
          page.value = page.value + 1;
          context.read(latestStateNotifier).getPosts("", page.value);
        },
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
            SliverPostGrid(
              key: gridKey.value,
              posts: currentPosts.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      body: CustomScrollView(
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
          SliverPostGridPlaceHolder(),
        ],
      ),
    );
  }
}
