// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/home/home_navigation_tile.dart';
import '../../../core/home/home_page_scaffold.dart';
import '../../../core/home/side_menu_tile.dart';
import '../../../core/posts/favorites/routes.dart';
import '../../../core/widgets/widgets.dart';
import '../favorites/favorites.dart';
import '../popular/e621_popular_page.dart';

class E621HomePage extends ConsumerStatefulWidget {
  const E621HomePage({
    super.key,
  });

  @override
  ConsumerState<E621HomePage> createState() => _E621HomePageState();
}

class _E621HomePageState extends ConsumerState<E621HomePage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;

    return HomePageScaffold(
      mobileMenu: [
        SideMenuTile(
          icon: const Icon(Symbols.explore),
          title: const Text('Popular'),
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(),
                body: const CustomContextMenuOverlay(
                  child: E621PopularPage(),
                ),
              ),
            ),
          ),
        ),
        if (config.hasLoginDetails()) ...[
          SideMenuTile(
            icon: const Icon(Symbols.favorite),
            title: Text('profile.favorites'.tr()),
            onTap: () => goToFavoritesPage(context),
          ),
        ],
      ],
      desktopMenuBuilder: (context, controller, constraints) => [
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.explore,
          icon: Symbols.explore,
          title: 'Popular',
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
      ],
      desktopViews: [
        const E621PopularPage(),
        if (config.hasLoginDetails()) ...[
          const E621FavoritesPage(),
        ],
      ],
    );
  }
}
