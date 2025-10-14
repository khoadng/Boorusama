// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/home/widgets.dart';
import '../../../core/posts/favorites/routes.dart';
import '../../../core/widgets/widgets.dart';
import '../configs/providers.dart';
import '../favorites/widgets.dart';
import '../popular/widgets.dart';

class E621HomePage extends ConsumerStatefulWidget {
  const E621HomePage({
    super.key,
  });

  @override
  ConsumerState<E621HomePage> createState() => _E621HomePageState();
}

class _E621HomePageState extends ConsumerState<E621HomePage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(e621LoginDetailsProvider(config));

    return HomePageScaffold(
      mobileMenu: [
        SideMenuTile(
          icon: const Icon(Symbols.explore),
          title: Text(context.t.explore.popular),
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              settings: const RouteSettings(name: 'popular'),
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: Text(context.t.explore.popular),
                ),
                body: const CustomContextMenuOverlay(
                  child: E621PopularPage(),
                ),
              ),
            ),
          ),
        ),
        if (loginDetails.hasLogin()) ...[
          SideMenuTile(
            icon: const Icon(Symbols.favorite),
            title: Text(context.t.profile.favorites),
            onTap: () => goToFavoritesPage(ref),
          ),
        ],
      ],
      desktopMenuBuilder: (context, constraints) => [
        HomeNavigationTile(
          value: 1,
          constraints: constraints,
          selectedIcon: Symbols.explore,
          icon: Symbols.explore,
          title: context.t.explore.popular,
        ),
        if (loginDetails.hasLogin()) ...[
          HomeNavigationTile(
            value: 2,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: context.t.profile.favorites,
          ),
        ],
      ],
      desktopViews: [
        const E621PopularPage(),
        if (loginDetails.hasLogin()) ...[
          const E621FavoritesPage(),
        ],
      ],
    );
  }
}
