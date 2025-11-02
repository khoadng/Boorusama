// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/boorus/engine/providers.dart';
import '../../../core/configs/config/providers.dart';
import '../../../core/home/widgets.dart';
import '../../../core/posts/favorites/routes.dart';
import '../favorites/widgets.dart';

class Shimmie2HomePage extends ConsumerStatefulWidget {
  const Shimmie2HomePage({
    super.key,
  });

  @override
  ConsumerState<Shimmie2HomePage> createState() => _Shimmie2HomePageState();
}

class _Shimmie2HomePageState extends ConsumerState<Shimmie2HomePage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(defaultLoginDetailsProvider(config));

    final favoritePageBuilder = ref
        .watch(booruBuilderProvider(config))
        ?.favoritesPageBuilder;

    return HomePageScaffold(
      mobileMenu: [
        if (favoritePageBuilder != null && loginDetails.hasLogin())
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
        if (favoritePageBuilder != null && loginDetails.hasLogin())
          HomeNavigationTile(
            value: 1,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
      ],
      desktopViews: [
        if (favoritePageBuilder != null) const Shimmie2FavoritesPage(),
      ],
    );
  }
}
