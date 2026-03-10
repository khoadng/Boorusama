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
import '../configs/extra_data.dart';
import '../favorites/widgets.dart';
import '../users/routes.dart';
import '../users/widgets.dart';

class EshuushuuHomePage extends ConsumerWidget {
  const EshuushuuHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(booruLoginDetailsProvider(config));
    final favoritePageBuilder = ref
        .watch(booruBuilderProvider(config))
        ?.favoritesPageBuilder;
    final extraData = EshuushuuExtraData.fromPassHash(config.passHash);
    final userId = extraData.userId;
    final isLoggedIn = loginDetails.hasLogin() && userId != null;

    return HomePageScaffold(
      mobileMenu: [
        if (isLoggedIn)
          SideMenuTile(
            icon: const Icon(Symbols.account_box),
            title: Text(context.t.profile.profile),
            onTap: () => goToEshuushuuUserDetailsPage(
              ref,
              userId: userId,
              username: config.login,
            ),
          ),
        if (favoritePageBuilder != null && isLoggedIn)
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
        if (isLoggedIn)
          HomeNavigationTile(
            value: 1,
            constraints: constraints,
            selectedIcon: Symbols.account_box,
            icon: Symbols.account_box,
            title: context.t.profile.profile,
          ),
        if (favoritePageBuilder != null && isLoggedIn)
          HomeNavigationTile(
            value: 2,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: context.t.profile.favorites,
          ),
      ],
      desktopViews: [
        if (isLoggedIn)
          EshuushuuUserDetailsPage(
            userId: userId,
            username: config.login,
          ),
        if (favoritePageBuilder != null && isLoggedIn)
          const EshuushuuFavoritesPage(),
      ],
    );
  }
}
