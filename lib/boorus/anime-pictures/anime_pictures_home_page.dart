// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../core/boorus/engine/providers.dart';
import '../../core/configs/ref.dart';
import '../../core/home/home_navigation_tile.dart';
import '../../core/home/home_page_scaffold.dart';
import '../../core/home/side_menu_tile.dart';
import '../../core/posts/favorites/routes.dart';
import '../../core/widgets/custom_context_menu_overlay.dart';
import 'anime_pictures.dart';
import 'anime_pictures_top_page.dart';

class AnimePicturesHomePage extends ConsumerStatefulWidget {
  const AnimePicturesHomePage({
    super.key,
  });

  @override
  ConsumerState<AnimePicturesHomePage> createState() =>
      _AnimePicturesHomePageState();
}

class _AnimePicturesHomePageState extends ConsumerState<AnimePicturesHomePage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final favoritePageBuilder =
        ref.watch(currentBooruBuilderProvider)?.favoritesPageBuilder;

    return HomePageScaffold(
      mobileMenu: [
        SideMenuTile(
          icon: const Icon(
            Symbols.explore,
            fill: 1,
          ),
          title: const Text('Top'),
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: const Text('Top'),
                ),
                body: const CustomContextMenuOverlay(
                  child: AnimePicturesTopPage(),
                ),
              ),
            ),
          ),
        ),
        if (favoritePageBuilder != null && config.passHash != null)
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
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.explore,
          icon: Symbols.explore,
          title: 'Top',
        ),
        if (favoritePageBuilder != null && config.passHash != null)
          HomeNavigationTile(
            value: 2,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
      ],
      desktopViews: [
        const AnimePicturesTopPage(),
        if (favoritePageBuilder != null && config.passHash != null)
          const AnimePicturesCurrentUserIdScope(
            child: AnimePicturesFavoritesPage(),
          ),
      ],
    );
  }
}
