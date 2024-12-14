// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/boorus/engine/providers.dart';
import '../../../core/configs/ref.dart';
import '../../../core/home/home_navigation_tile.dart';
import '../../../core/home/home_page_scaffold.dart';
import '../../../core/home/side_menu_tile.dart';
import '../../../core/posts/favorites/routes.dart';
import '../gelbooru_v2.dart';

class GelbooruV2HomePage extends ConsumerStatefulWidget {
  const GelbooruV2HomePage({
    super.key,
  });

  @override
  ConsumerState<GelbooruV2HomePage> createState() => _GelbooruV2HomePageState();
}

class _GelbooruV2HomePageState extends ConsumerState<GelbooruV2HomePage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final favoritePageBuilder =
        ref.watch(currentBooruBuilderProvider)?.favoritesPageBuilder;

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
      desktopMenuBuilder: (context, controller, constraints) => [
        if (favoritePageBuilder != null && config.hasLoginDetails())
          HomeNavigationTile(
            value: 1,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
      ],
      desktopViews: [
        if (favoritePageBuilder != null) const GelbooruV2FavoritesPage(),
      ],
    );
  }
}
