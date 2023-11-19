// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/sankaku/sankaku.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/core/pages/bookmarks/bookmark_page.dart';
import 'package:boorusama/core/pages/downloads/bulk_download_page.dart';
import 'package:boorusama/core/pages/home/side_menu_tile.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';

class SankakuHomePage extends ConsumerWidget {
  const SankakuHomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final login = config.login;

    return BooruScope(
      config: config,
      mobileView: (controller) => MobileHomePageScaffold(
        controller: controller,
        onSearchTap: () => goToSearchPage(context),
      ),
      mobileMenuBuilder: (context, controller) => [
        if (login != null)
          SideMenuTile(
            icon: const Icon(Icons.favorite_outline),
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
          selectedIcon: const Icon(Icons.dashboard),
          icon: const Icon(Icons.dashboard_outlined),
          title: 'Home',
        ),
        const Divider(),
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.bookmark),
          icon: const Icon(Icons.bookmark_border_outlined),
          title: 'sideMenu.your_bookmarks'.tr(),
        ),
        HomeNavigationTile(
          value: 2,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.list_alt),
          icon: const Icon(Icons.list_alt_outlined),
          title: 'sideMenu.your_blacklist'.tr(),
        ),
        HomeNavigationTile(
          value: 3,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.download),
          icon: const Icon(Icons.download_outlined),
          title: 'sideMenu.bulk_download'.tr(),
        ),
        const Divider(),
        if (login != null)
          HomeNavigationTile(
            value: 4,
            controller: controller,
            constraints: constraints,
            selectedIcon: const Icon(Icons.favorite),
            icon: const Icon(Icons.favorite_border_outlined),
            title: 'Favorites',
          ),
        HomeNavigationTile(
          value: 999,
          controller: controller,
          constraints: constraints,
          selectedIcon: const Icon(Icons.settings),
          icon: const Icon(Icons.settings),
          title: 'sideMenu.settings'.tr(),
          onTap: () => context.go('/settings'),
        ),
      ],
      desktopViews: [
        const DesktopHomePageScaffold(),
        const BookmarkPage(),
        const BlacklistedTagPage(),
        const BulkDownloadPage(),
        if (login != null) SankakuFavoritesPage(username: login)
      ],
    );
  }
}

class SankakuFavoritesPage extends ConsumerWidget {
  const SankakuFavoritesPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final query = 'fav:$username';

    return FavoritesPageScaffold(
      favQueryBuilder: () => query,
      fetcher: (page) =>
          ref.read(sankakuPostRepoProvider(config)).getPosts([query], page),
    );
  }
}
