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
import '../../../core/widgets/custom_context_menu_overlay.dart';
import '../favorites/widgets.dart';
import '../tops/widgets.dart';
import '../users/widgets.dart';

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
    final favoritePageBuilder = ref
        .watch(booruBuilderProvider(config))
        ?.favoritesPageBuilder;

    return HomePageScaffold(
      mobileMenu: [
        SideMenuTile(
          icon: const Icon(
            Symbols.explore,
            fill: 1,
          ),
          title: Text(context.t.explore.top),
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: Text(context.t.explore.top),
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
            title: Text(context.t.profile.favorites),
            onTap: () {
              goToFavoritesPage(ref);
            },
          ),
      ],
      desktopMenuBuilder: (context, constraints) => [
        HomeNavigationTile(
          value: 1,
          constraints: constraints,
          selectedIcon: Symbols.explore,
          icon: Symbols.explore,
          title: context.t.explore.top,
        ),
        if (favoritePageBuilder != null && config.passHash != null)
          HomeNavigationTile(
            value: 2,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: context.t.profile.favorites,
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
