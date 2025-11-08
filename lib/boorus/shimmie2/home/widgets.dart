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
import '../extensions/page.dart';
import '../extensions/routes.dart';
import '../favorites/providers.dart';
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

    final favoritePageBuilder = ref
        .watch(booruBuilderProvider(config))
        ?.favoritesPageBuilder;

    return HomePageScaffold(
      mobileMenu: [
        if (favoritePageBuilder != null)
          if (ref.watch(shimmie2CanFavoriteProvider(config)) case AsyncData(
            value: final canFavorite,
          ) when canFavorite)
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
        SideMenuTile(
          icon: const Icon(Symbols.extension),
          title: Text(context.t.shimmie2.extension.title),
          onTap: () {
            goToShimmie2ExtensionsPage(ref);
          },
        ),
      ],
      desktopMenuBuilder: (context, constraints) => [
        if (favoritePageBuilder != null)
          switch (ref.watch(shimmie2CanFavoriteProvider(config))) {
            (AsyncData() || AsyncLoading()) && final s => HomeNavigationTile(
              value: 1,
              constraints: constraints,
              selectedIcon: Symbols.favorite,
              icon: Symbols.favorite,
              title: context.t.profile.favorites,
              enabled: switch (s) {
                AsyncData(:final value) => value,
                _ => false,
              },
            ),
            _ => const SizedBox.shrink(),
          },
        HomeNavigationTile(
          value: favoritePageBuilder != null ? 2 : 1,
          constraints: constraints,
          selectedIcon: Symbols.extension,
          icon: Symbols.extension,
          title: context.t.shimmie2.extension.title,
        ),
      ],
      desktopViews: [
        if (favoritePageBuilder != null) const Shimmie2FavoritesPage(),
        const Shimmie2ExtensionsPage(),
      ],
    );
  }
}
