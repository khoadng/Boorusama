import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/search_bar.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/generated/i18n.dart';
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
import 'side_bar.dart';

class HomePage extends HookWidget {
  HomePage({Key key}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final int tabLength = 4;

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
    final bottomTabIndex = useState(0);

    useEffect(() {
      Future.microtask(
          () => context.read(authenticationStateNotifierProvider).logIn());
      return () => {};
    }, []);

    return Scaffold(
      key: scaffoldKey,
      drawer: SideBarMenu(),
      resizeToAvoidBottomInset: false,
      body: DefaultTabController(
        length: tabLength,
        child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverSafeArea(
                    top: false,
                    sliver: SliverAppBar(
                      toolbarHeight: kToolbarHeight * 1.2,
                      title: SearchBar(
                        enabled: false,
                        leading: IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () =>
                              scaffoldKey.currentState.openDrawer(),
                        ),
                        onTap: () => AppRouter.router
                            .navigateTo(context, "/posts/search/"),
                      ),
                      shape: Border(
                        bottom: BorderSide(color: Colors.grey[400], width: 1.0),
                      ),
                      floating: true,
                      pinned: true,
                      snap: false,
                      primary: true,
                      forceElevated: innerBoxIsScrolled,
                      automaticallyImplyLeading: false,
                      bottom: TabBar(
                        isScrollable: true,
                        unselectedLabelColor:
                            Theme.of(context).unselectedWidgetColor,
                        labelColor: Theme.of(context).accentColor,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: MD2Indicator(
                          indicatorHeight: 4,
                          indicatorColor: Theme.of(context).accentColor,
                          indicatorSize: MD2IndicatorSize.full,
                        ),
                        tabs: [
                          Tab(text: I18n.of(context).postCategoriesLatest),
                          Tab(text: I18n.of(context).postCategoriesPopular),
                          Tab(text: I18n.of(context).postCategoriesCurated),
                          Tab(text: I18n.of(context).postCategoriesMostViewed),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: <Widget>[
                LatestView(),
                PopularView(),
                CuratedView(),
                MostViewedView(),
              ],
            )),
      ),
      bottomNavigationBar: BottomBar(
        onTabChanged: (value) => bottomTabIndex.value = value,
      ),
    );
  }
}
