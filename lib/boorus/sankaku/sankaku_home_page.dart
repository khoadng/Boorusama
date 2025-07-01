// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../core/configs/auth/widgets.dart';
import '../../core/configs/ref.dart';
import '../../core/home/home_navigation_tile.dart';
import '../../core/home/home_page_scaffold.dart';
import '../../core/home/side_menu_tile.dart';
import '../../core/posts/favorites/routes.dart';
import '../../core/scaffolds/scaffolds.dart';
import 'sankaku.dart';

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
              goToFavoritesPage(ref);
            },
          ),
      ],
      desktopMenuBuilder: (context, constraints) => [
        if (login != null)
          HomeNavigationTile(
            value: 1,
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
      builder: (_) => SankakuFavoritesPageInternal(
        username: config.login!,
      ),
    );
  }
}

class SankakuFavoritesPageInternal extends ConsumerWidget {
  const SankakuFavoritesPageInternal({
    required this.username,
    super.key,
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
