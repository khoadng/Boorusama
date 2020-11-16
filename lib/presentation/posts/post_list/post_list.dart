import 'package:boorusama/application/posts/post_download/bloc/post_download_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/presentation/posts/post_list/models/post_list_action.dart';
import 'package:boorusama/presentation/posts/post_list/pages/all_posts_page.dart';
import 'package:boorusama/presentation/posts/post_list/pages/popular_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';

import 'widgets/searches/search_bar.dart';

class PostList extends StatefulWidget {
  PostList(
      {Key key,
      @required this.posts,
      @required this.onMaxItemReached,
      @required this.onMenuTap,
      @required this.onSearched,
      @required this.scrollThreshold,
      @required this.scrollController,
      this.onScrollDirectionChanged})
      : super(key: key);

  final List<Post> posts;
  final VoidCallback onMaxItemReached;
  final ValueChanged<String> onSearched;
  final VoidCallback onMenuTap;
  final ValueChanged<ScrollDirection> onScrollDirectionChanged;
  final scrollThreshold;
  final scrollController;

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  bool _isScrollingDown = false;

  final List<String> _tabs = <String>[
    "All",
    "Popular",
    "Curated",
    "Most Viewed"
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: NestedScrollView(
        floatHeaderSlivers: true,
        controller: widget.scrollController..addListener(_onScroll),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          // These are the slivers that show up in the "outer" scroll view.
          return <Widget>[
            SliverOverlapAbsorber(
              // This widget takes the overlapping behavior of the SliverAppBar,
              // and redirects it to the SliverOverlapInjector below. If it is
              // missing, then it is possible for the nested "inner" scroll view
              // below to end up under the SliverAppBar even when the inner
              // scroll view thinks it has not been scrolled.
              // This is not necessary if the "headerSliverBuilder" only builds
              // widgets that do not overlap the next sliver.
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverSafeArea(
                top: false,
                sliver: SliverAppBar(
                  title: SearchBar(
                    onMenuTap: widget.onMenuTap,
                    onSearched: widget.onSearched,
                    onMoreSelected: (value) => _handleMoreSelected(value),
                  ),
                  shape: Border(
                    bottom: BorderSide(color: Colors.grey[400], width: 1.0),
                  ),
                  floating: true,
                  pinned: true,
                  snap: true,
                  primary: true,
                  forceElevated: true,
                  automaticallyImplyLeading: false,
                  bottom: TabBar(
                    unselectedLabelColor:
                        Theme.of(context).unselectedWidgetColor,
                    labelColor: Theme.of(context).accentColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: MD2Indicator(
                      indicatorHeight: 4,
                      indicatorColor: Theme.of(context).accentColor,
                      indicatorSize: MD2IndicatorSize.full,
                    ),
                    // These are the widgets to put in each tab in the tab bar.
                    tabs: _tabs.map((String name) => Tab(text: name)).toList(),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          // These are the contents of the tab views, below the tabs.
          children: <Widget>[
            AllPostsPage(posts: widget.posts),
            PopularPage(),
            Center(
              child: Text("Curated"),
            ),
            Center(
              child: Text("Most Viewed"),
            ),
          ],
        ),
      ),
    );
  }

  void _onScroll() {
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final currentScroll = widget.scrollController.position.pixels;
    final currentThresholdPercent = currentScroll / maxScroll;

    if (currentThresholdPercent >= widget.scrollThreshold) {
      widget.onMaxItemReached?.call();
    }

    if (widget.scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!_isScrollingDown) {
        _isScrollingDown = true;
        widget.onScrollDirectionChanged?.call(ScrollDirection.reverse);
      }
    } else if (widget.scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (_isScrollingDown) {
        _isScrollingDown = false;
        widget.onScrollDirectionChanged?.call(ScrollDirection.forward);
      }
    }
  }

  void _handleMoreSelected(PostListAction action) {
    switch (action) {
      case PostListAction.downloadAll:
        _downloadAllPosts();
        break;
      default:
    }
  }

  void _downloadAllPosts() {
    widget.posts.forEach((post) {
      context
          .read<PostDownloadBloc>()
          .add(PostDownloadEvent.downloaded(post: post));
    });
  }
}
