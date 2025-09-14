// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/home/home_navigation_tile.dart';
import '../../../core/home/home_page_scaffold.dart';
import '../../../core/home/side_menu_tile.dart';
import '../../../core/posts/favorites/routes.dart';
import '../configs/providers.dart';
import '../favorites/widgets.dart';

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
        if (loginDetails.hasLogin()) ...[
          SideMenuTile(
            icon: const Icon(Symbols.favorite),
            title: Text(context.t.profile.favorites),
            onTap: () => goToFavoritesPage(ref),
          ),
        ],
      ],
      desktopMenuBuilder: (context, constraints) => [
        if (loginDetails.hasLogin()) ...[
          HomeNavigationTile(
            value: 1,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
        ],
      ],
      desktopViews: [
        if (loginDetails.hasLogin()) ...[
          const SzurubooruFavoritesPage(),
        ],
      ],
    );
  }
}
