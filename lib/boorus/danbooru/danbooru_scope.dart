// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/widgets/home_search_bar.dart';
import 'package:boorusama/boorus/core/widgets/network_indicator_with_state.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/pages/blacklisted_tags/blacklisted_tags_page.dart';
import 'package:boorusama/boorus/danbooru/pages/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/pages/favorites/favorite_groups_page.dart';
import 'package:boorusama/boorus/danbooru/pages/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/pages/forums/danbooru_forum_page.dart';
import 'package:boorusama/boorus/danbooru/pages/home/danbooru_bottom_bar.dart';
import 'package:boorusama/boorus/danbooru/pages/home/latest_posts_view.dart';
import 'package:boorusama/boorus/danbooru/pages/home/other_features_page.dart';
import 'package:boorusama/boorus/danbooru/pages/pool/pool_page.dart';
import 'package:boorusama/boorus/danbooru/pages/saved_search/saved_search_feed_page.dart';
import 'package:boorusama/boorus/danbooru/pages/search/danbooru_search_page.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/home_page_scope.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/animated_indexed_stack.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';

class DanbooruScope extends StatefulWidget {
  const DanbooruScope({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  State<DanbooruScope> createState() => _DanbooruScopeState();
}

class _DanbooruScopeState extends State<DanbooruScope> {
  @override
  Widget build(BuildContext context) {
    return HomePageScope(
      bottomBar: (context, controller) => ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, child) => DanbooruBottomBar(
          initialValue: value,
          onTabChanged: (value) => controller.goToTab(value),
        ),
      ),
      builder: (context, tab, controller) => DanbooruProvider(
        builder: (context) {
          return isMobilePlatform()
              ? AnnotatedRegion(
                  key: ValueKey(widget.config.id),
                  value: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: context.themeMode.isLight
                        ? Brightness.dark
                        : Brightness.light,
                  ),
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: Column(
                      children: [
                        const NetworkUnavailableIndicatorWithState(),
                        Expanded(
                            child: ValueListenableBuilder(
                          valueListenable: controller,
                          builder: (context, value, child) =>
                              AnimatedIndexedStack(
                            index: value,
                            children: [
                              LatestView(
                                toolbarBuilder: (context) => SliverAppBar(
                                  backgroundColor:
                                      context.theme.scaffoldBackgroundColor,
                                  toolbarHeight: kToolbarHeight * 1.2,
                                  primary: true,
                                  title: HomeSearchBar(
                                    onMenuTap: controller.openMenu,
                                    onTap: () => goToSearchPage(context),
                                  ),
                                  floating: true,
                                  snap: true,
                                  automaticallyImplyLeading: false,
                                ),
                              ),
                              const ExplorePage(),
                              const OtherFeaturesPage(),
                            ],
                          ),
                        )),
                      ],
                    ),
                    bottomNavigationBar: tab,
                  ),
                )
              : ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, value, child) => AnimatedIndexedStack(
                    index: value,
                    children: [
                      LatestView(
                        toolbarBuilder: (context) =>
                            const SliverSizedBox.shrink(),
                      ),
                      const ExplorePage(),
                      const DanbooruSearchPage(),
                      const PoolPage(),
                      const DanbooruForumPage(),
                      FavoritesPage(username: widget.config.login!),
                      const FavoriteGroupsPage(),
                      const SavedSearchFeedPage(),
                      const BlacklistedTagsPage(),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
