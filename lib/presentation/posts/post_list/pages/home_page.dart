import 'package:boorusama/application/authentication/bloc/authentication_bloc.dart';
import 'package:boorusama/application/posts/post_search/bloc/post_search_bloc.dart';
import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/presentation/posts/post_download_gallery/post_download_gallery_page.dart';
import 'package:boorusama/presentation/posts/post_list/models/post_list_action.dart';
import 'package:boorusama/presentation/posts/post_list/pages/browse_all_page.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/searches/search_bar.dart';
import 'package:boorusama/presentation/ui/bottom_bar_widget.dart';
import 'package:boorusama/presentation/ui/drawer/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';

import 'popular_page.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _tabs = <String>[
    "All",
    "Popular",
    "Curated",
    "Most Viewed"
  ];

  int _currentTab = 0;

  Account _account;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          setState(() {
            _account = state.account;
          });
        } else if (state is Unauthenticated) {
          //TODO: dirty solution, unused parameter
          setState(() {
            _account = null;
          });
        }
      },
      child: SafeArea(
        child: Scaffold(
          key: widget.scaffoldKey,
          drawer: SideBarMenu(
            account: _account,
          ),
          resizeToAvoidBottomInset: false,
          body: _getPage(_currentTab, context),
          bottomNavigationBar: BottomBar(
            onTabChanged: (value) => _handleTabChanged(value),
          ),
        ),
      ),
    );
  }

  Widget _buildTabView() {
    return DefaultTabController(
      length: _tabs.length,
      child: NestedScrollView(
        floatHeaderSlivers: true,
        // controller: widget.scrollController..addListener(_onScroll),
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
                    onRemoveTap: () => BlocProvider.of<PostSearchBloc>(context)
                        .add(PostSearchEvent.postSearched(query: "", page: 1)),
                    onMenuTap: () =>
                        widget.scaffoldKey.currentState.openDrawer(),
                    onSearched: (query) =>
                        BlocProvider.of<PostSearchBloc>(context).add(
                            PostSearchEvent.postSearched(
                                query: query, page: 1)),
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
            BrowseAllPage(),
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

  void _handleTabChanged(int tabIndex) {
    setState(() {
      _currentTab = tabIndex;
    });
  }

  //TODO: refactor
  Widget _getPage(int tabIndex, BuildContext context) {
    switch (tabIndex) {
      case 0:
        return Stack(
          fit: StackFit.expand,
          children: [
            _buildTabView(),
            BlocBuilder<PostSearchBloc, PostSearchState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loading: (query, page) => Positioned(
                    bottom: 0,
                    child: Container(
                      height: 3,
                      width: MediaQuery.of(context).size.width,
                      child: LinearProgressIndicator(),
                    ),
                  ),
                  orElse: () => Center(),
                );
              },
            ),
          ],
        );
      case 1:
        return PostDownloadGalleryPage();
    }
  }

  void _handleMoreSelected(PostListAction action) {
    // switch (action) {
    //   case PostListAction.downloadAll:
    //     _downloadAllPosts();
    //     break;
    //   default:
    // }
  }
}
