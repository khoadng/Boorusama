// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/core/pages/bookmarks/bookmark_page.dart';
import 'package:boorusama/core/pages/downloads/bulk_download_page.dart';
import 'package:boorusama/core/pages/home/side_menu_tile.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/utils/flutter_utils.dart';
import 'e621_desktop_home_page.dart';
import 'e621_favorites_page.dart';
import 'e621_popular_page.dart';

class E621HomePage extends ConsumerStatefulWidget {
  const E621HomePage({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  ConsumerState<E621HomePage> createState() => _E621HomePageState();
}

class _E621HomePageState extends ConsumerState<E621HomePage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;

    return BooruScope(
      config: widget.config,
      mobileView: (controller) => PostScope(
        fetcher: (page) =>
            ref.read(e621PostRepoProvider(config)).getPosts([], page),
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
            const SliverAppAnnouncementBanner(),
          ],
        ),
      ),
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
                    body: const CustomContextMenuOverlay(
                        child: E621PopularPage()),
                  ))),
        ),
        if (config.hasLoginDetails()) ...[
          SideMenuTile(
            icon: const Icon(Icons.favorite_outline),
            title: Text('profile.favorites'.tr()),
            onTap: () => goToFavoritesPage(context),
          ),
        ]
      ],
      desktopMenuBuilder: (context, controller, constraints) => [
        HomeNavigationTile(
          value: 0,
          controller: controller,
          constraints: constraints,
          selectedIcon: Icons.dashboard,
          icon: Icons.dashboard_outlined,
          title: 'Home',
        ),
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: Icons.explore,
          icon: Icons.explore_outlined,
          title: 'Explore',
        ),
        if (config.hasLoginDetails()) ...[
          HomeNavigationTile(
            value: 2,
            controller: controller,
            constraints: constraints,
            selectedIcon: Icons.favorite,
            icon: Icons.favorite_border_outlined,
            title: 'Favorites',
          ),
        ],
        const Divider(),
        HomeNavigationTile(
          value: 3,
          controller: controller,
          constraints: constraints,
          selectedIcon: Icons.bookmark,
          icon: Icons.bookmark_border_outlined,
          title: 'sideMenu.your_bookmarks'.tr(),
        ),
        HomeNavigationTile(
          value: 4,
          controller: controller,
          constraints: constraints,
          selectedIcon: Icons.list_alt,
          icon: Icons.list_alt_outlined,
          title: 'sideMenu.your_blacklist'.tr(),
        ),
        HomeNavigationTile(
          value: 5,
          controller: controller,
          constraints: constraints,
          selectedIcon: Icons.download,
          icon: Icons.download_outlined,
          title: 'sideMenu.bulk_download'.tr(),
        ),
        const Divider(),
        HomeNavigationTile(
          value: 999,
          controller: controller,
          constraints: constraints,
          selectedIcon: Icons.settings,
          icon: Icons.settings,
          title: 'sideMenu.settings'.tr(),
          onTap: () => context.go('/settings'),
        ),
      ],
      desktopViews: [
        const E621DesktopHomePage(),
        const E621PopularPage(),
        if (config.hasLoginDetails()) ...[
          E621FavoritesPage(
            username: config.login!,
          ),
        ] else ...[
          //TODO: hacky way to prevent accessing wrong index... Will need better solution
          const SizedBox(),
        ],
        const BookmarkPage(),
        const BlacklistedTagPage(),
        const BulkDownloadPage(),
      ],
    );
  }
}
