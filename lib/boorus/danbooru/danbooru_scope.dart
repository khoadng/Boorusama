// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/boorus/core/pages/bookmarks/bookmark_page.dart';
import 'package:boorusama/boorus/core/pages/downloads/bulk_download_page.dart';
import 'package:boorusama/boorus/core/pages/home/side_menu_tile.dart';
import 'package:boorusama/boorus/core/widgets/booru_scope.dart';
import 'package:boorusama/boorus/core/widgets/home_navigation_tile.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/pages/blacklisted_tags/blacklisted_tags_page.dart';
import 'package:boorusama/boorus/danbooru/pages/explore/explore_page.dart';
import 'package:boorusama/boorus/danbooru/pages/favorites/favorite_groups_page.dart';
import 'package:boorusama/boorus/danbooru/pages/favorites/favorites_page.dart';
import 'package:boorusama/boorus/danbooru/pages/forums/danbooru_forum_page.dart';
import 'package:boorusama/boorus/danbooru/pages/home/danbooru_home_page.dart';
import 'package:boorusama/boorus/danbooru/pages/home/latest_posts_view.dart';
import 'package:boorusama/boorus/danbooru/pages/pool/pool_page.dart';
import 'package:boorusama/boorus/danbooru/pages/saved_search/saved_search_feed_page.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/utils/flutter_utils.dart';

class DanbooruScope extends ConsumerStatefulWidget {
  const DanbooruScope({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  ConsumerState<DanbooruScope> createState() => _DanbooruScopeState();
}

class _DanbooruScopeState extends ConsumerState<DanbooruScope> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authenticationProvider);

    return DanbooruProvider(
      builder: (context) => BooruScope(
        config: widget.config,
        mobileView: (controller) => LatestView(
          searchBar: HomeSearchBar(
            onMenuTap: controller.openMenu,
            onTap: () => goToSearchPage(context),
          ),
        ),
        mobileMenuBuilder: (context, controller) => [
          SideMenuTile(
            icon: const Icon(Icons.explore),
            title: const Text('Explore'),
            onTap: () => context.navigator.push(MaterialPageRoute(
                builder: (_) => Scaffold(
                      appBar: AppBar(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      ),
                      body: const ExplorePage(),
                    ))),
          ),
          SideMenuTile(
            icon: const Icon(Icons.photo_album_outlined),
            title: const Text('Pools'),
            onTap: () {
              goToPoolPage(context, ref);
            },
          ),
          SideMenuTile(
            icon: const Icon(Icons.forum_outlined),
            title: const Text('forum.forum').tr(),
            onTap: () {
              goToForumPage(context);
            },
          ),
          if (auth.isAuthenticated) ...[
            SideMenuTile(
              icon: const Icon(Icons.favorite_outline),
              title: Text('profile.favorites'.tr()),
              onTap: () {
                goToFavoritesPage(context, widget.config.login);
              },
            ),
            SideMenuTile(
              icon: const Icon(Icons.collections),
              title: const Text('favorite_groups.favorite_groups').tr(),
              onTap: () {
                goToFavoriteGroupPage(context);
              },
            ),
            SideMenuTile(
              icon: const Icon(Icons.search),
              title: const Text('saved_search.saved_search').tr(),
              onTap: () {
                goToSavedSearchPage(context, widget.config.login);
              },
            ),
            SideMenuTile(
              icon: const FaIcon(FontAwesomeIcons.ban, size: 20),
              title: const Text(
                'blacklisted_tags.blacklisted_tags',
              ).tr(),
              onTap: () {
                goToBlacklistedTagPage(context);
              },
            ),
          ]
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
            selectedIcon: const Icon(Icons.photo_album),
            icon: const Icon(Icons.photo_album_outlined),
            title: 'Pools',
          ),
          HomeNavigationTile(
            value: 3,
            controller: controller,
            constraints: constraints,
            selectedIcon: const Icon(Icons.forum),
            icon: const Icon(Icons.forum_outlined),
            title: 'forum.forum'.tr(),
          ),
          if (auth.isAuthenticated) ...[
            HomeNavigationTile(
              value: 4,
              controller: controller,
              constraints: constraints,
              selectedIcon: const Icon(Icons.favorite),
              icon: const Icon(Icons.favorite_border_outlined),
              title: 'Favorites',
            ),
            HomeNavigationTile(
              value: 5,
              controller: controller,
              constraints: constraints,
              selectedIcon: const Icon(Icons.collections),
              icon: const Icon(Icons.collections_outlined),
              title: 'favorite_groups.favorite_groups'.tr(),
            ),
            HomeNavigationTile(
              value: 6,
              controller: controller,
              constraints: constraints,
              selectedIcon: const Icon(Icons.saved_search),
              icon: const Icon(Icons.saved_search_outlined),
              title: 'saved_search.saved_search'.tr(),
            ),
            HomeNavigationTile(
              value: 7,
              controller: controller,
              constraints: constraints,
              selectedIcon: const Icon(Icons.tag),
              icon: const Icon(Icons.tag_outlined),
              title: 'blacklisted_tags.blacklisted_tags'.tr(),
            ),
          ],
          const Divider(),
          HomeNavigationTile(
            value: 8,
            controller: controller,
            constraints: constraints,
            selectedIcon: const Icon(Icons.bookmark),
            icon: const Icon(Icons.bookmark_border_outlined),
            title: 'sideMenu.your_bookmarks'.tr(),
          ),
          HomeNavigationTile(
            value: 9,
            controller: controller,
            constraints: constraints,
            selectedIcon: const Icon(Icons.list_alt),
            icon: const Icon(Icons.list_alt_outlined),
            title: 'sideMenu.your_blacklist'.tr(),
          ),
          HomeNavigationTile(
            value: 10,
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
        desktopViews: [
          const DanbooruHomePage(),
          const ExplorePage(),
          const PoolPage(),
          const DanbooruForumPage(),
          if (auth.isAuthenticated) ...[
            FavoritesPage(username: widget.config.login!),
            const FavoriteGroupsPage(),
            const SavedSearchFeedPage(),
            const BlacklistedTagsPage(),
          ] else ...[
            //TODO: hacky way to prevent accessing wrong index... Will need better solution
            const SizedBox(),
            const SizedBox(),
            const SizedBox(),
            const SizedBox(),
          ],
          const BookmarkPage(),
          const BlacklistedTagPage(),
          const BulkDownloadPage(),
        ],
      ),
    );
  }
}
