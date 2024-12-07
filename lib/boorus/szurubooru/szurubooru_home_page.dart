// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/home/home_navigation_tile.dart';
import 'package:boorusama/core/home/home_page_scaffold.dart';
import 'package:boorusama/core/home/side_menu_tile.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'szurubooru.dart';

class SzurubooruHomePage extends ConsumerWidget {
  const SzurubooruHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return HomePageScaffold(
      mobileMenu: [
        if (config.hasLoginDetails()) ...[
          SideMenuTile(
            icon: const Icon(Symbols.favorite),
            title: Text('profile.favorites'.tr()),
            onTap: () => goToFavoritesPage(context),
          ),
        ]
      ],
      desktopMenuBuilder: (context, controller, constraints) => [
        if (config.hasLoginDetails()) ...[
          HomeNavigationTile(
            value: 1,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
        ],
      ],
      desktopViews: [
        if (config.hasLoginDetails()) ...[
          const SzurubooruFavoritesPage(),
        ],
      ],
    );
  }
}
