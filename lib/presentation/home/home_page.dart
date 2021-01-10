import 'package:boorusama/application/authentication/bloc/authentication_bloc.dart';
import 'package:boorusama/application/home/home_bloc.dart';
import 'package:boorusama/domain/accounts/account.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/presentation/home/post_list_action.dart';
import 'package:boorusama/application/home/browse_all/browse_all_bloc.dart';
import 'package:boorusama/presentation/home/curated_view.dart';
import 'package:boorusama/presentation/home/most_viewed_view.dart';
import 'package:boorusama/application/home/popular/popular_bloc.dart';
import 'package:boorusama/presentation/home/widgets/searches/search_bar.dart';
import 'package:boorusama/presentation/posts/post_download_gallery/post_download_gallery_page.dart';
import 'package:boorusama/presentation/ui/bottom_bar_widget.dart';
import 'package:boorusama/presentation/ui/drawer/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';

import 'browse_all/browse_all_view.dart';
import 'popular/popular_view.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final List<String> _tabs = <String>[
    "All",
    "Popular",
    "Curated",
    "Most Viewed"
  ];
  final SearchBarController _searchBarController = SearchBarController();
  TabController _tabController;

  int _currentBottomTab = 0;

  Account _account;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    _tabController.dispose();
    super.dispose();
  }

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
          body: _getPage(_currentBottomTab, context),
          bottomNavigationBar: BottomBar(
            onTabChanged: (value) => BlocProvider.of<HomeBloc>(context)
                .add(HomeEvent.bottomTabChanged(tabIndex: value)),
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
                  title: BlocListener<HomeBloc, HomeState>(
                    listener: (context, state) {
                      setState(() {
                        _searchBarController.assignQuery(state.query);
                        _tabController.index = state.topTabIndex;
                        _currentBottomTab = state.bottomTabIndex;
                      });
                    },
                    child: SearchBar(
                      controller: _searchBarController,
                      onRemoveTap: () => BlocProvider.of<HomeBloc>(context)
                          .add(HomeEvent.reset()),
                      onMenuTap: () =>
                          widget.scaffoldKey.currentState.openDrawer(),
                      onSearched: (query) => BlocProvider.of<HomeBloc>(context)
                          .add(HomeEvent.searched(query: query)),
                      onMoreSelected: (value) => _handleMoreSelected(value),
                    ),
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
                    isScrollable: true,
                    controller: _tabController,
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
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          // These are the contents of the tab views, below the tabs.
          children: <Widget>[
            BlocProvider(
              create: (context) => BrowseAllBloc(
                settingRepository: GetIt.instance<ISettingRepository>(),
                postRepository: GetIt.instance<IPostRepository>(),
              )..add(BrowseAllEvent.started()),
              child: BlocConsumer<HomeBloc, HomeState>(
                listener: (context, state) {
                  BlocProvider.of<BrowseAllBloc>(context)
                      .add(BrowseAllEvent.searched(query: state.query));
                },
                listenWhen: (previous, current) =>
                    current.query != previous.query,
                builder: (context, state) {
                  return BrowseAllView(
                    initialQuery: state.query,
                  );
                },
              ),
            ),
            BlocProvider(
              create: (context) => PopularBloc(
                settingRepository: GetIt.instance<ISettingRepository>(),
                postRepository: GetIt.instance<IPostRepository>(),
              )..add(PopularEvent.started()),
              child: PopularView(),
            ),
            CuratedView(),
            MostViewedView(),
          ],
        ),
      ),
    );
  }

  //TODO: refactor
  Widget _getPage(int tabIndex, BuildContext context) {
    switch (tabIndex) {
      case 0:
        return Stack(
          fit: StackFit.expand,
          children: [
            _buildTabView(),
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
