// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/e621/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/popular/e621_popular_page.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';

class E621HomePage extends ConsumerStatefulWidget {
  const E621HomePage({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  ConsumerState<E621HomePage> createState() => _E621HomePageState();
}

class _E621HomePageState extends ConsumerState<E621HomePage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;

    return HomePageScaffold(
      mobileMenu: [
        SideMenuTile(
          icon: const Icon(Symbols.explore),
          title: const Text('Popular'),
          onTap: () => context.navigator.push(CupertinoPageRoute(
              builder: (_) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Popular'),
                    ),
                    body: const CustomContextMenuOverlay(
                        child: E621PopularPage()),
                  ))),
        ),
        if (config.hasLoginDetails()) ...[
          SideMenuTile(
            icon: const Icon(Symbols.favorite),
            title: Text('profile.favorites'.tr()),
            onTap: () => goToFavoritesPage(context),
          ),
        ]
      ],
      desktopMenuBuilder: (context, controller, constraints) => [
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.explore,
          icon: Symbols.explore,
          title: 'Popular',
        ),
        if (config.hasLoginDetails()) ...[
          HomeNavigationTile(
            value: 2,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
        ],
      ],
      desktopViews: [
        const E621PopularPage(),
        if (config.hasLoginDetails()) ...[
          E621FavoritesPage(
            username: config.login!,
          ),
        ],
      ],
    );
  }
}
