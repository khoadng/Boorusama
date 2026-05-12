// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/home/widgets.dart';
import '../../../core/posts/favorites/routes.dart';
import '../configs/providers.dart';
import '../favorites/widgets.dart';
import '../pools/routes.dart';
import '../pools/widgets.dart';

class SzurubooruHomePage extends ConsumerWidget {
  const SzurubooruHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(szurubooruLoginDetailsProvider(config));

    return HomePageScaffold(
      mobileMenu: [
        SideMenuTile(
          icon: const Icon(Symbols.photo_library),
          title: Text(context.t.pool.pools),
          onTap: () => goToSzurubooruPoolPage(ref),
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
          selectedIcon: Symbols.photo_library,
          icon: Symbols.photo_library,
          title: context.t.pool.pools,
        ),
        if (loginDetails.hasLogin()) ...[
          HomeNavigationTile(
            value: 2,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
        ],
      ],
      desktopViews: [
        const SzurubooruPoolPage(),
        if (loginDetails.hasLogin()) ...[
          const SzurubooruFavoritesPage(),
        ],
      ],
    );
  }
}
