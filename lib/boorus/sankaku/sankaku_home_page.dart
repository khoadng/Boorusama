// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/sankaku/sankaku.dart';
import 'package:boorusama/core/configs/failsafe.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/home/home_navigation_tile.dart';
import 'package:boorusama/core/home/home_page_scaffold.dart';
import 'package:boorusama/core/home/side_menu_tile.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';

class SankakuHomePage extends ConsumerWidget {
  const SankakuHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final login = config.login;

    return HomePageScaffold(
      mobileMenu: [
        if (login != null)
          SideMenuTile(
            icon: const Icon(Symbols.favorite),
            title: Text('profile.favorites'.tr()),
            onTap: () {
              goToFavoritesPage(context);
            },
          ),
      ],
      desktopMenuBuilder: (context, controller, constraints) => [
        if (login != null)
          HomeNavigationTile(
            value: 1,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
      ],
      desktopViews: [if (login != null) const SankakuFavoritesPage()],
    );
  }
}

class SankakuFavoritesPage extends ConsumerWidget {
  const SankakuFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return BooruConfigAuthFailsafe(
      child: SankakuFavoritesPageInternal(
        username: config.login!,
      ),
    );
  }
}

class SankakuFavoritesPageInternal extends ConsumerWidget {
  const SankakuFavoritesPageInternal({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigSearch;
    final query = 'fav:$username';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) =>
          ref.read(sankakuPostRepoProvider(config)).getPosts(query, page),
    );
  }
}
