// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/gelbooru_v2/gelbooru_v2.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'gelbooru_v2_desktop_home_page.dart';

class GelbooruV2HomePage extends ConsumerStatefulWidget {
  const GelbooruV2HomePage({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  ConsumerState<GelbooruV2HomePage> createState() => _GelbooruV2HomePageState();
}

class _GelbooruV2HomePageState extends ConsumerState<GelbooruV2HomePage> {
  @override
  Widget build(BuildContext context) {
    final favoritePageBuilder =
        ref.watchBooruBuilder(ref.watchConfig)?.favoritesPageBuilder;

    return BooruScope(
      config: widget.config,
      mobileMenuBuilder: (context, controller) => [
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
        HomeNavigationTile(
          value: 0,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.dashboard,
          icon: Symbols.dashboard,
          title: 'Home',
        ),
        if (favoritePageBuilder != null && ref.watchConfig.hasLoginDetails())
          HomeNavigationTile(
            value: 1,
            controller: controller,
            constraints: constraints,
            selectedIcon: Symbols.favorite,
            icon: Symbols.favorite,
            title: 'Favorites',
          ),
        ...coreDesktopTabBuilder(
          context,
          constraints,
          controller,
        ),
      ],
      desktopViews: () {
        final gelbooruTabs = [
          const GelbooruV2DesktopHomePage(),
          if (favoritePageBuilder != null && ref.watchConfig.hasLoginDetails())
            GelbooruV2FavoritesPage(uid: ref.watchConfig.login!),
        ];

        return [
          ...gelbooruTabs,
          ...coreDesktopViewBuilder(
            previousItemCount: gelbooruTabs.length,
          ),
        ];
      },
    );
  }
}
