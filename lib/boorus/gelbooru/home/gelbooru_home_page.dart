// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/gelbooru/favorites/favorites.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';

class GelbooruHomePage extends ConsumerStatefulWidget {
  const GelbooruHomePage({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  ConsumerState<GelbooruHomePage> createState() => _GelbooruHomePageState();
}

class _GelbooruHomePageState extends ConsumerState<GelbooruHomePage> {
  @override
  Widget build(BuildContext context) {
    final favoritePageBuilder =
        ref.watchBooruBuilder(ref.watchConfig)?.favoritesPageBuilder;

    return HomePageScaffold(
      mobileMenuBuilder: [
        if (favoritePageBuilder != null && ref.watchConfig.hasLoginDetails())
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
        if (favoritePageBuilder != null && ref.watchConfig.hasLoginDetails())
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
        if (favoritePageBuilder != null && ref.watchConfig.hasLoginDetails())
          GelbooruFavoritesPage(uid: ref.watchConfig.login!),
      ],
    );
  }
}
