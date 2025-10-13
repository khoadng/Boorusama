// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/home/widgets.dart';
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
          title: context.t.profile.favorites,
        ),
      ],
      desktopViews: const [
        HydrusFavoritesPage(),
      ],
    );
  }
}
