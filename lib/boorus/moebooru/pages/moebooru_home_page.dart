// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/boorus/engine/providers.dart';
import '../../../core/configs/ref.dart';
import '../../../core/home/home_navigation_tile.dart';
import '../../../core/home/home_page_scaffold.dart';
import '../../../core/home/side_menu_tile.dart';
import '../../../core/posts/favorites/routes.dart';
import '../../../core/widgets/widgets.dart';
import 'moebooru_popular_page.dart';
import 'moebooru_popular_recent_page.dart';

class MoebooruHomePage extends ConsumerStatefulWidget {
  const MoebooruHomePage({
    super.key,
  });

  @override
  ConsumerState<MoebooruHomePage> createState() => _MoebooruHomePageState();
}

class _MoebooruHomePageState extends ConsumerState<MoebooruHomePage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final favoritesPageBuilder =
        ref.watch(booruBuilderProvider(config))?.favoritesPageBuilder;

    return HomePageScaffold(
      mobileMenu: [
        SideMenuTile(
          icon: const Icon(
            Symbols.explore,
            fill: 1,
          ),
          title: const Text('Popular'),
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              settings: const RouteSettings(name: 'popular'),
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: const Text('Popular'),
                ),
                body: const CustomContextMenuOverlay(
                  child: MoebooruPopularPage(),
                ),
              ),
            ),
          ),
        ),
        SideMenuTile(
          icon: const Icon(
            Symbols.local_fire_department,
            fill: 1,
          ),
          title: const Text('Hot'),
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              settings: const RouteSettings(name: 'hot'),
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: const Text('Hot'),
                ),
                body: const CustomContextMenuOverlay(
                  child: MoebooruPopularRecentPage(),
                ),
              ),
            ),
          ),
        ),
        if (config.hasLoginDetails()) ...[
          SideMenuTile(
            icon: const Icon(
              Symbols.favorite,
              fill: 1,
            ),
            title: Text('profile.favorites'.tr()),
            onTap: () {
              goToFavoritesPage(context);
            },
          ),
        ],
      ],
      desktopMenuBuilder: (context, constraints) => [
        HomeNavigationTile(
          value: 1,
          constraints: constraints,
          selectedIcon: Symbols.explore,
          icon: Symbols.explore,
          title: 'Popular',
        ),
        HomeNavigationTile(
          value: 2,
          constraints: constraints,
          selectedIcon: Symbols.local_fire_department,
          icon: Symbols.local_fire_department,
          title: 'Hot',
        ),
        if (favoritesPageBuilder != null && config.hasLoginDetails())
          HomeNavigationTile(
            value: 3,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
      ],
      desktopViews: [
        const MoebooruPopularPage(),
        const MoebooruPopularRecentPage(),
        if (favoritesPageBuilder != null && config.hasLoginDetails())
          favoritesPageBuilder(context),
      ],
    );
  }
}
