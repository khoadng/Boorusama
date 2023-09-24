// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/boorus/core/pages/bookmarks/bookmark_page.dart';
import 'package:boorusama/boorus/core/widgets/booru_scope.dart';
import 'package:boorusama/boorus/core/widgets/home_navigation_tile.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'desktop_home_page_scaffold.dart';
import 'mobile_home_page_scaffold.dart';

class HomePageScaffold extends ConsumerStatefulWidget {
  const HomePageScaffold({
    super.key,
    required this.onPostTap,
    required this.onSearchTap,
  });

  final void Function(
    BuildContext context,
    List<Post> posts,
    Post post,
    AutoScrollController scrollController,
    Settings settings,
    int initialIndex,
  ) onPostTap;
  final void Function() onSearchTap;

  @override
  ConsumerState<HomePageScaffold> createState() => _HomePageScaffoldState();
}

class _HomePageScaffoldState extends ConsumerState<HomePageScaffold> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watch(currentBooruConfigProvider);

    return BooruScope(
      config: config,
      mobileView: (controller) => MobileHomePageScaffold(
        controller: controller,
        onPostTap: widget.onPostTap,
        onSearchTap: widget.onSearchTap,
      ),
      mobileMenuBuilder: (context, controller) => [],
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
        // HomeNavigationTile(
        //   value: 3,
        //   controller: controller,
        //   constraints: constraints,
        //   selectedIcon: const Icon(Icons.download),
        //   icon: const Icon(Icons.download_outlined),
        //   title: 'sideMenu.bulk_download'.tr(),
        // ),
        const Divider(),
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
        DesktopHomePageScaffold(
          onPostTap: widget.onPostTap,
        ),
        const BookmarkPage(),
        const BlacklistedTagPage(),
      ],
    );
  }
}
