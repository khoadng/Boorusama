// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/boorus/core/pages/bookmarks/bookmark_page.dart';
import 'package:boorusama/boorus/core/pages/downloads/bulk_download_page.dart';
import 'package:boorusama/boorus/core/pages/home/side_menu_tile.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/boorus/core/widgets/booru_scope.dart';
import 'package:boorusama/boorus/core/widgets/home_navigation_tile.dart';
import 'package:boorusama/boorus/core/widgets/home_search_bar.dart';
import 'package:boorusama/boorus/core/widgets/posts/post_scope.dart';
import 'package:boorusama/boorus/home_page.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/moebooru_popular_page.dart';
import 'package:boorusama/boorus/moebooru/moebooru_popular_recent_page.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'moebooru_home_page.dart';

class MoebooruScope extends ConsumerStatefulWidget {
  const MoebooruScope({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  ConsumerState<MoebooruScope> createState() => _DanbooruScopeState();
}

class _DanbooruScopeState extends ConsumerState<MoebooruScope> {
  @override
  Widget build(BuildContext context) {
    return BooruScope(
      config: widget.config,
      mobileView: (controller) => _buildMobileHomeView(controller),
      mobileMenuBuilder: (context, controller) => [
        SideMenuTile(
          icon: const Icon(Icons.explore),
          title: const Text('Popular'),
          onTap: () => context.navigator.push(MaterialPageRoute(
              builder: (_) => Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                    ),
                    body: const MoebooruPopularPage(),
                  ))),
        ),
        SideMenuTile(
          icon: const Icon(Icons.local_fire_department),
          title: const Text('Hot'),
          onTap: () => context.navigator.push(MaterialPageRoute(
              builder: (_) => Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                    ),
                    body: const MoebooruPopularRecentPage(),
                  ))),
        ),
      ],
      desktopMenuBuilder: (context, controller, constraints) => [
        HomeNavigationTile(
          value: 0,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.dashboard),
          icon: const Icon(Icons.dashboard_outlined),
          title: 'Home',
        ),
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.explore),
          icon: const Icon(Icons.explore_outlined),
          title: 'Explore',
        ),
        HomeNavigationTile(
          value: 2,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.local_fire_department),
          icon: const Icon(Icons.local_fire_department_outlined),
          title: 'Hot',
        ),
        const Divider(),
        HomeNavigationTile(
          value: 3,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.bookmark),
          icon: const Icon(Icons.bookmark_border_outlined),
          title: 'sideMenu.your_bookmarks'.tr(),
        ),
        HomeNavigationTile(
          value: 4,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.list_alt),
          icon: const Icon(Icons.list_alt_outlined),
          title: 'sideMenu.your_blacklist'.tr(),
        ),
        HomeNavigationTile(
          value: 5,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.download),
          icon: const Icon(Icons.download_outlined),
          title: 'sideMenu.bulk_download'.tr(),
        ),
        const Divider(),
        HomeNavigationTile(
          value: 999,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.settings),
          icon: const Icon(Icons.settings),
          title: 'sideMenu.settings'.tr(),
          onTap: () => context.go('/settings'),
        ),
      ],
      desktopViews: const [
        MoebooruHomePage(),
        MoebooruPopularPage(),
        MoebooruPopularRecentPage(),
        BookmarkPage(),
        BlacklistedTagPage(),
        BulkDownloadPage(),
      ],
    );
  }

  Widget _buildMobileHomeView(HomePageController controller) {
    return PostScope(
      fetcher: (page) =>
          ref.read(moebooruPostRepoProvider).getPostsFromTags('', page),
      builder: (context, postController, errors) => InfinitePostListScaffold(
        errors: errors,
        controller: postController,
        sliverHeaderBuilder: (context) => [
          SliverAppBar(
            backgroundColor: context.theme.scaffoldBackgroundColor,
            toolbarHeight: kToolbarHeight * 1.2,
            title: HomeSearchBar(
              onMenuTap: controller.openMenu,
              onTap: () => goToSearchPage(context),
            ),
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
          ),
        ],
      ),
    );
  }
}
