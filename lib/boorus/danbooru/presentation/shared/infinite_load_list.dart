// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/presentation/hooks/hooks.dart';
import 'sliver_post_grid.dart';

class InfiniteLoadList extends HookWidget {
  const InfiniteLoadList({
    Key key,
    @required this.scrollController,
    @required this.gridKey,
    @required this.posts,
    @required this.refreshController,
    this.onRefresh,
    this.onLoadMore,
    this.onItemChanged,
    this.headers,
    this.child,
    this.extendBody = false,
  }) : super(key: key);

  final AutoScrollController scrollController;
  final GlobalKey gridKey;
  final List<Post> posts;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final ValueChanged<int> onItemChanged;
  final List<Widget> headers;
  final Widget child;
  final RefreshController refreshController;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final lastViewedPostIndex = useState(-1);
    useValueChanged(lastViewedPostIndex.value, (_, __) {
      scrollController.scrollToIndex(lastViewedPostIndex.value);
    });
    final hideFabAnimController = useAnimationController(
        duration: kThemeAnimationDuration, initialValue: 1);
    final scrollControllerWithAnim = useScrollControllerForAnimation(
        hideFabAnimController, scrollController);

    return Scaffold(
      floatingActionButton: FadeTransition(
        opacity: hideFabAnimController,
        child: ScaleTransition(
          scale: hideFabAnimController,
          child: extendBody
              ? Padding(
                  padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                  child: FloatingActionButton(
                    heroTag: null,
                    child: FaIcon(FontAwesomeIcons.angleDoubleUp),
                    onPressed: () => scrollControllerWithAnim.jumpTo(0.0),
                  ),
                )
              : FloatingActionButton(
                  heroTag: null,
                  child: FaIcon(FontAwesomeIcons.angleDoubleUp),
                  onPressed: () => scrollControllerWithAnim.jumpTo(0.0),
                ),
        ),
      ),
      body: SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        enablePullDown: onRefresh != null ? true : false,
        header: const MaterialClassicHeader(),
        footer: const ClassicFooter(),
        onRefresh: () => onRefresh(),
        onLoading: () => onLoadMore(),
        child: CustomScrollView(
          controller: scrollControllerWithAnim,
          slivers: <Widget>[
            if (headers != null) ...headers,
            SliverPadding(
              padding: EdgeInsets.all(6.0),
              sliver: child ??
                  SliverPostGrid(
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
                    scrollController: scrollControllerWithAnim,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
