import 'package:boorusama/application/home/latest/latest_state_notifier.dart';
import 'package:boorusama/presentation/home/refreshable_list.dart';
import 'package:boorusama/presentation/home/sliver_post_grid_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

final latestStateNotifier = StateNotifierProvider<LatestStateNotifier>(
    (ref) => LatestStateNotifier(ref));

class LatestView extends StatefulWidget {
  LatestView({Key key}) : super(key: key);

  @override
  _LatestViewState createState() => _LatestViewState();
}

class _LatestViewState extends State<LatestView>
    with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    Future.delayed(
        Duration.zero, () => context.read(latestStateNotifier).getPosts("", 1));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderListener<LatestState>(
      provider: latestStateNotifier.state,
      onChange: (context, state) {
        state.maybeWhen(
            fetched: (posts, page, query) => _refreshController
              ..loadComplete()
              ..refreshCompleted(),
            orElse: () {});
      },
      child: Consumer(
        builder: (context, watch, child) {
          final state = watch(latestStateNotifier.state);
          return state.when(
              initial: () => Center(),
              loading: () => Scaffold(
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
                  ),
              fetched: (posts, page, query) {
                return Scaffold(
                  body: RefreshableList(
                    posts: posts,
                    onLoadMore: () => context
                        .read(latestStateNotifier)
                        .getMorePosts(posts, query, page),
                    onRefresh: () =>
                        context.read(latestStateNotifier).refresh(),
                    refreshController: _refreshController,
                  ),
                );
              });
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
