import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/account.dart';
import 'package:boorusama/generated/i18n.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';

import 'bottom_bar_widget.dart';
import 'curated/curated_view.dart';
import 'latest/latest_posts_view.dart';
import 'most_viewed/most_viewed_view.dart';
import 'popular/popular_view.dart';
import 'post_list_action.dart';
import 'search_bar.dart';
import 'side_bar.dart';

class HomePage extends HookWidget {
  HomePage({Key key}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final int tabLength = 4;

  // Widget _buildTabView(int topTabIndex) {
  //   return
  // }

  // //TODO: refactor
  // Widget _getPage(int tabIndex, BuildContext context, int topTabIndex) {
  //   switch (tabIndex) {
  //     case 0:
  //       return
  //     // case 1:
  //     // return PostDownloadGalleryPage();
  //   }
  // }

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
    //TODO: MEMORY LEAK HERE, CUSTOM HOOK NEEDED
    final searchBarController = useState(SearchBarController());

    final bottomTabIndex = useState(0);
    final topTabIndex = useState(0);

    useEffect(() {
      Future.microtask(
          () => context.read(authenticationStateNotifierProvider).logIn());
      return () => {};
    }, []);

    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        drawer: SideBarMenu(),
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            DefaultTabController(
              length: tabLength,
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
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                        sliver: SliverSafeArea(
                          top: false,
                          sliver: SliverAppBar(
                            title: SearchBar(
                              controller: searchBarController.value,
                              onRemoveTap: () {},
                              onMenuTap: () =>
                                  scaffoldKey.currentState.openDrawer(),
                              onTap: () {
                                showSearch(
                                  context: context,
                                  delegate: SearchPage(
                                      searchFieldStyle: Theme.of(context)
                                          .inputDecorationTheme
                                          .hintStyle),
                                );
                              },
                              onMoreSelected: (value) =>
                                  _handleMoreSelected(value),
                            ),
                            shape: Border(
                              bottom: BorderSide(
                                  color: Colors.grey[400], width: 1.0),
                            ),
                            floating: true,
                            pinned: true,
                            snap: true,
                            primary: true,
                            forceElevated: true,
                            automaticallyImplyLeading: false,
                            bottom: TabBar(
                              onTap: (value) => topTabIndex.value = value,
                              isScrollable: true,
                              controller: tabController,
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
                              tabs: [
                                Tab(
                                    text:
                                        I18n.of(context).postCategoriesLatest),
                                Tab(
                                    text:
                                        I18n.of(context).postCategoriesPopular),
                                Tab(
                                    text:
                                        I18n.of(context).postCategoriesCurated),
                                Tab(
                                    text: I18n.of(context)
                                        .postCategoriesMostViewed),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: IndexedStack(
                    index: topTabIndex.value,
                    children: <Widget>[
                      LatestView(),
                      PopularView(),
                      CuratedView(),
                      MostViewedView(),
                    ],
                  )),
            ),
          ],
        ),
        bottomNavigationBar: BottomBar(
          onTabChanged: (value) => bottomTabIndex.value = value,
        ),
      ),
    );
  }
}

// class HomePage extends StatefulWidget {
//   HomePage({Key key}) : super(key: key);

//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage>
//     with SingleTickerProviderStateMixin {
//   final int tabLength = 4;

//   Account _account;
//   int _currentBottomTab = 0;
//   int _currentTopTab = 0;
//   final SearchBarController _searchBarController = SearchBarController();
//   TabController _tabController;

//   @override
//   void dispose() {
//     _searchBarController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: tabLength, vsync: this);
//   }

//   void _handleMoreSelected(PostListAction action) {
//     // switch (action) {
//     //   case PostListAction.downloadAll:
//     //     _downloadAllPosts();
//     //     break;
//     //   default:
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthenticationBloc, AuthenticationState>(
//       listener: (context, state) {
//         if (state is Authenticated) {
//           setState(() {
//             _account = state.account;
//           });
//         } else if (state is Unauthenticated) {
//           //TODO: dirty solution, unused parameter
//           setState(() {
//             _account = null;
//           });
//         }
//       },
//       child: SafeArea(
//         child: Scaffold(
//           key: widget.scaffoldKey,
//           drawer: SideBarMenu(
//             account: _account,
//           ),
//           resizeToAvoidBottomInset: false,
//           body: _getPage(_currentBottomTab, context),
//           bottomNavigationBar: BottomBar(
//             onTabChanged: (value) {
//               setState(() {
//                 _currentBottomTab = value;
//               });
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
