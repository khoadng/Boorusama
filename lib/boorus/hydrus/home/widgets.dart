// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/home/home_navigation_tile.dart';
import '../../../core/home/home_page_scaffold.dart';
import '../../../core/home/side_menu_tile.dart';
import '../../../core/posts/favorites/routes.dart';
import '../favorites/widgets.dart';

class HydrusHomePage extends ConsumerWidget {
  const HydrusHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HomePageScaffold(
      mobileMenu: [
        SideMenuTile(
          icon: const Icon(Symbols.favorite),
          title: Text(context.t.profile.favorites),
          onTap: () => goToFavoritesPage(ref),
        ),
      ],
      desktopMenuBuilder: (context, constraints) => [
        HomeNavigationTile(
          value: 1,
          constraints: constraints,
          selectedIcon: Symbols.favorite,
          icon: Symbols.favorite,
          title: 'Favorites'.hc,
        ),
      ],
      desktopViews: const [
        HydrusFavoritesPage(),
      ],
    );
  }
}
