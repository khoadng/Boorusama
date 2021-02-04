// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/infrastructure/networking/network_info.dart';
import 'package:boorusama/core/presentation/widgets/animated_indexed_stack.dart';
import 'package:boorusama/generated/i18n.dart';
import 'bottom_bar_widget.dart';
import 'explore/explore_page.dart';
import 'latest/latest_posts_view.dart';
import 'post_list_action.dart';
import 'side_bar.dart';

class HomePage extends HookWidget {
  HomePage({Key key}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final int tabLength = 2;

  void _handleMoreSelected(PostListAction action) {
    // switch (action) {
    //   case PostListAction.downloadAll:
    //     _downloadAllPosts();
    //     break;
    //   default:
    // }
  }

  @override
  Widget build(BuildContext context) {
    final tickerProvider = useSingleTickerProvider();
    final tabController =
        useTabController(initialLength: tabLength, vsync: tickerProvider);

    final bottomTabIndex = useState(0);
    final topTabIndex = useState(0);

    final networkStatus = useProvider(networkStatusProvider);

    useEffect(() {
      Future.microtask(
          () => context.read(authenticationStateNotifierProvider).logIn());
      return () => {};
    }, []);

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            networkStatus.when(
              data: (value) => value.when(
                unknown: () => SizedBox.shrink(),
                available: () => SizedBox.shrink(),
                unavailable: () => Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.black,
                    child: Text("Network unavailable"),
                  ),
                ),
              ),
              loading: () => Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Theme.of(context).appBarTheme.color,
                  child: Text("Connecting"),
                ),
              ),
              error: (error, stackTrace) => Material(
                color: Theme.of(context).appBarTheme.color,
                child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text("Something went wrong")),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Scaffold(
                  key: scaffoldKey,
                  drawer: SideBarMenu(),
                  resizeToAvoidBottomInset: false,
                  body: IndexedStack(
                    index: bottomTabIndex.value,
                    children: <Widget>[
                      _buildHomeTabBottomBar(topTabIndex, tabController),
                      FavoritesPage(),
                    ],
                  ),
                  bottomNavigationBar: BottomBar(
                    onTabChanged: (value) => bottomTabIndex.value = value,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTabBottomBar(
      ValueNotifier<int> topTabIndex, TabController tabController) {
    return DefaultTabController(
      length: tabLength,
      child: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverSafeArea(
              top: false,
              sliver: SliverAppBar(
                toolbarHeight: kToolbarHeight * 1.2,
                title: SearchBar(
                  enabled: false,
                  leading: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () => scaffoldKey.currentState.openDrawer(),
                  ),
                  onTap: () =>
                      AppRouter.router.navigateTo(context, "/posts/search/"),
                ),
                shape: Border(
                  bottom: BorderSide(color: Colors.grey[400], width: 1.0),
                ),
                floating: false,
                pinned: true,
                snap: false,
                primary: true,
                forceElevated: true,
                automaticallyImplyLeading: false,
                bottom: TabBar(
                  onTap: (value) => topTabIndex.value = value,
                  isScrollable: true,
                  controller: tabController,
                  unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
                  labelColor: Theme.of(context).accentColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: MD2Indicator(
                    indicatorHeight: 4,
                    indicatorColor: Theme.of(context).accentColor,
                    indicatorSize: MD2IndicatorSize.full,
                  ),
                  tabs: [
                    Tab(text: I18n.of(context).postCategoriesLatest),
                    Tab(text: "Explore"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: AnimatedIndexedStack(
          index: topTabIndex.value,
          children: <Widget>[
            LatestView(),
            ExplorePage(),
          ],
        ),
      ),
    );
  }
}
