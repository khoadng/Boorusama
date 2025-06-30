// Flutter imports:
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
import '../favorites/favorites.dart';

class GelbooruHomePage extends ConsumerStatefulWidget {
  const GelbooruHomePage({
    super.key,
  });

  @override
  ConsumerState<GelbooruHomePage> createState() => _GelbooruHomePageState();
}

class _GelbooruHomePageState extends ConsumerState<GelbooruHomePage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final favoritePageBuilder =
        ref.watch(booruBuilderProvider(config))?.favoritesPageBuilder;

    return HomePageScaffold(
      mobileMenu: [
        if (favoritePageBuilder != null && config.hasLoginDetails())
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
      desktopMenuBuilder: (context, constraints) => [
        if (favoritePageBuilder != null && config.hasLoginDetails())
          HomeNavigationTile(
            value: 1,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
      ],
      desktopViews: [
        if (favoritePageBuilder != null) const GelbooruFavoritesPage(),
      ],
    );
  }
}
