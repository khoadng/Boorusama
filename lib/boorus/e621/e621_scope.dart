// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/boorus/core/pages/bookmarks/bookmark_page.dart';
import 'package:boorusama/boorus/core/pages/downloads/bulk_download_page.dart';
import 'package:boorusama/boorus/core/pages/home/side_menu_tile.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/boorus/core/widgets/booru_scope.dart';
import 'package:boorusama/boorus/core/widgets/home_navigation_tile.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/pages/favorites/e621_favorites_page.dart';
import 'package:boorusama/boorus/e621/pages/home/e621_home_page.dart';
import 'package:boorusama/boorus/e621/pages/popular/e621_popular_page.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/utils/flutter_utils.dart';

class E621Scope extends ConsumerStatefulWidget {
  const E621Scope({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  ConsumerState<E621Scope> createState() => _E621ScopeState();
}

class _E621ScopeState extends ConsumerState<E621Scope> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authenticationProvider);

    return BooruScope(
      config: widget.config,
      mobileView: (controller) => PostScope(
        fetcher: (page) => ref.read(e621PostRepoProvider).getPosts('', page),
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
          onPostTap: (context, posts, post, scrollController, settings,
                  initialIndex) =>
              goToPostDetailsPage(
            context: context,
            posts: posts,
            initialIndex: initialIndex,
            scrollController: scrollController,
          ),
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
                    body: const E621PopularPage(),
                  ))),
        ),
        if (auth.isAuthenticated) ...[
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
          title: 'Popular',
        ),
        if (auth.isAuthenticated) ...[
          HomeNavigationTile(
            value: 2,
            controller: controller,
            constraints: constraints,
            selectedIcon: const Icon(Icons.favorite),
            icon: const Icon(Icons.favorite_border_outlined),
            title: 'Favorites',
          ),
        ],
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
      desktopViews: [
        const E621HomePage(),
        const E621PopularPage(),
        if (auth.isAuthenticated) ...[
          const E621FavoritesPage(),
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
