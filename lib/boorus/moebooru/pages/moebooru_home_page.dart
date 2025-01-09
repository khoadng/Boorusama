// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'moebooru_popular_page.dart';
import 'moebooru_popular_recent_page.dart';

class MoebooruHomePage extends ConsumerStatefulWidget {
  const MoebooruHomePage({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  ConsumerState<MoebooruHomePage> createState() => _MoebooruHomePageState();
}

class _MoebooruHomePageState extends ConsumerState<MoebooruHomePage> {
  @override
  Widget build(BuildContext context) {
    return HomePageScaffold(
      mobileMenu: [
        SideMenuTile(
          icon: const Icon(
            Symbols.explore,
            fill: 1,
          ),
          title: const Text('Popular'),
          onTap: () => context.navigator.push(
            CupertinoPageRoute(
              settings: const RouteSettings(name: 'popular'),
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: const Text('Popular'),
                ),
                body: const CustomContextMenuOverlay(
                  child: MoebooruPopularPage(),
                ),
              ),
            ),
          ),
        ),
        SideMenuTile(
          icon: const Icon(
            Symbols.local_fire_department,
            fill: 1,
          ),
          title: const Text('Hot'),
          onTap: () => context.navigator.push(
            CupertinoPageRoute(
              settings: const RouteSettings(name: 'hot'),
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: const Text('Hot'),
                ),
                body: const CustomContextMenuOverlay(
                  child: MoebooruPopularRecentPage(),
                ),
              ),
            ),
          ),
        ),
        if (widget.config.hasLoginDetails()) ...[
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
      ],
      desktopMenuBuilder: (context, constraints) => [
        HomeNavigationTile(
          value: 1,
          constraints: constraints,
          selectedIcon: Symbols.explore,
          icon: Symbols.explore,
          title: 'Popular',
        ),
        HomeNavigationTile(
          value: 2,
          constraints: constraints,
          selectedIcon: Symbols.local_fire_department,
          icon: Symbols.local_fire_department,
          title: 'Hot',
        ),
      ],
      desktopViews: const [
        MoebooruPopularPage(),
        MoebooruPopularRecentPage(),
      ],
    );
  }
}
