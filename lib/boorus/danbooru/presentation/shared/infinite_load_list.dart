// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/list_item_status.dart';
import 'sliver_post_grid.dart';

class InfiniteLoadList extends HookWidget {
  const InfiniteLoadList({
    Key key,
    @required this.scrollController,
    @required this.gridKey,
    @required this.posts,
    @required this.stateProvider,
    this.onRefresh,
    this.onLoadMore,
    this.onItemChanged,
    this.header,
  }) : super(key: key);

  final AutoScrollController scrollController;
  final GlobalKey gridKey;
  final List<Post> posts;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final ValueChanged<int> onItemChanged;
  final Provider<ListItemStatus<Post>> stateProvider;
  final Widget header;

  @override
  Widget build(BuildContext context) {
    final refreshController =
        useState(RefreshController(initialRefresh: false));
    final lastViewedPostIndex = useState(-1);
    useValueChanged(lastViewedPostIndex.value, (_, __) {
      scrollController.scrollToIndex(lastViewedPostIndex.value);
    });
    return ProviderListener<ListItemStatus<Post>>(
      provider: stateProvider,
      onChange: (context, state) {
        state.maybeWhen(
          fetched: () {
            refreshController.value.loadComplete();
            if (onRefresh != null) {
              refreshController.value.refreshCompleted();
            }
          },
          error: () => Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text("Something went wrong"))),
          orElse: () {},
        );
      },
      child: SmartRefresher(
        controller: refreshController.value,
        enablePullUp: true,
        enablePullDown: onRefresh != null ? true : false,
        header: const MaterialClassicHeader(),
        footer: const ClassicFooter(),
        onRefresh: () => onRefresh(),
        onLoading: () => onLoadMore(),
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            if (header != null) ...[header],
            SliverPadding(
              padding: EdgeInsets.all(6.0),
              sliver: SliverPostGrid(
                key: gridKey,
                onTap: (post, index) async {
                  final newIndex = await AppRouter.router.navigateTo(
                    context,
                    "/posts",
                    routeSettings: RouteSettings(arguments: [
                      post,
                      index,
                      posts,
                      () => null,
                      (index) {
                        onItemChanged(index);
                      },
                      gridKey,
                    ]),
                  );

                  lastViewedPostIndex.value = newIndex;
                },
                posts: posts,
                scrollController: scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
