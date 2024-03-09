// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/home/side_menu_tile.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
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
          icon: const Icon(Symbols.explore),
          title: const Text('Popular'),
          onTap: () => context.navigator.push(CupertinoPageRoute(
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
            icon: const Icon(Symbols.favorite),
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
          selectedIcon: Symbols.dashboard,
          icon: Symbols.dashboard,
          title: 'Home',
        ),
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.explore,
          icon: Symbols.explore,
          title: 'Explore',
        ),
        if (config.hasLoginDetails()) ...[
          HomeNavigationTile(
            value: 2,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
        ],
        ...coreDesktopTabBuilder(
          context,
          constraints,
          controller,
        ),
      ],
      desktopViews: () {
        final e621Tabs = [
          const E621DesktopHomePage(),
          const E621PopularPage(),
          if (config.hasLoginDetails()) ...[
            E621FavoritesPage(
              username: config.login!,
            ),
          ],
        ];

        return [
          ...e621Tabs,
          ...coreDesktopViewBuilder(
            previousItemCount: e621Tabs.length,
          ),
        ];
      },
    );
  }
}
