// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/entry_page.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/core/pages/bookmarks/bookmark_page.dart';
import 'package:boorusama/core/pages/downloads/bulk_download_page.dart';
import 'package:boorusama/core/widgets/booru_scope.dart';
import 'package:boorusama/core/widgets/home_navigation_tile.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'desktop_home_page_scaffold.dart';
import 'mobile_home_page_scaffold.dart';

class HomePageScaffold extends ConsumerStatefulWidget {
  const HomePageScaffold({
    super.key,
    required this.onPostTap,
    required this.onSearchTap,
    this.mobileMenuBuilder,
  });

  final void Function(
    BuildContext context,
    Iterable<Post> posts,
    Post post,
    AutoScrollController scrollController,
    Settings settings,
    int initialIndex,
  ) onPostTap;
  final void Function() onSearchTap;

  final List<Widget> Function(
    BuildContext context,
    HomePageController controller,
  )? mobileMenuBuilder;

  @override
  ConsumerState<HomePageScaffold> createState() => _HomePageScaffoldState();
}

class _HomePageScaffoldState extends ConsumerState<HomePageScaffold> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;

    return BooruScope(
      config: config,
      mobileView: (controller) => MobileHomePageScaffold(
        controller: controller,
        onSearchTap: widget.onSearchTap,
      ),
      mobileMenuBuilder: (context, controller) =>
          widget.mobileMenuBuilder != null
              ? widget.mobileMenuBuilder!(context, controller)
              : [],
      desktopMenuBuilder: (context, controller, constraints) => [
        HomeNavigationTile(
          value: 0,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.dashboard,
          icon: Symbols.dashboard,
          title: 'Home',
        ),
        const Divider(),
        HomeNavigationTile(
          value: 1,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.bookmark,
          icon: Symbols.bookmark,
          title: 'sideMenu.your_bookmarks'.tr(),
        ),
        HomeNavigationTile(
          value: 2,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.list_alt,
          icon: Symbols.list_alt,
          title: 'sideMenu.your_blacklist'.tr(),
        ),
        HomeNavigationTile(
          value: 3,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.download,
          icon: Symbols.download,
          title: 'sideMenu.bulk_download'.tr(),
        ),
        const Divider(),
        HomeNavigationTile(
          value: 999,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.settings,
          icon: Symbols.settings,
          title: 'sideMenu.settings'.tr(),
          onTap: () => context.go('/settings'),
        ),
      ],
      desktopViews: const [
        DesktopHomePageScaffold(),
        BookmarkPage(),
        BlacklistedTagPage(),
        BulkDownloadPage(),
      ],
    );
  }
}
