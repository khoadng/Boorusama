// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../blacklists/widgets.dart';
import '../bookmarks/widgets.dart';
import '../boorus/engine/providers.dart';
import '../cache/providers.dart';
import '../downloads/bulks.dart';
import '../downloads/manager.dart';
import '../foundation/display.dart';
import '../settings/routes.dart';
import '../tags/favorites/widgets.dart';
import '../widgets/widgets.dart';
import 'booru_scope.dart';
import 'home_navigation_tile.dart';
import 'home_page_controller.dart';

class HomePageScaffold extends ConsumerStatefulWidget {
  const HomePageScaffold({
    super.key,
    this.mobileMenu,
    this.desktopMenuBuilder,
    this.desktopViews,
  });

  final List<Widget>? mobileMenu;

  final List<Widget> Function(
    BuildContext context,
    BoxConstraints constraints,
  )? desktopMenuBuilder;

  final List<Widget>? desktopViews;

  @override
  ConsumerState<HomePageScaffold> createState() => _HomePageScaffoldState();
}

class _HomePageScaffoldState extends ConsumerState<HomePageScaffold> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final controller = HomePageController(scaffoldKey: scaffoldKey);

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customHome = ref.watch(currentBooruBuilderProvider)?.homeViewBuilder;

    final menuWidth = ref.watch(miscDataProvider(kMenuWidthCacheKey));

    final views = [
      if (customHome != null)
        customHome(context, controller)
      else
        const Scaffold(
          body: Center(child: Text('No home view builder found')),
        ),
      if (widget.desktopViews != null) ...widget.desktopViews!,
    ]
        .mapIndexed(
          (i, e) => Scaffold(
            appBar: !context.isLargeScreen && i > 0
                ? AppBar(
                    leading: BackButton(
                      onPressed: () {
                        controller.goToTab(0);
                      },
                    ),
                  )
                : null,
            body: e,
          ),
        )
        .toList();

    return InheritedHomePageController(
      controller: controller,
      child: HomePageSidebarKeyboardListener(
        controller: controller,
        child: CustomContextMenuOverlay(
          child: BooruScope(
            controller: controller,
            menuBuilder: (context, constraints) => [
              HomeNavigationTile(
                value: 0,
                constraints: constraints,
                selectedIcon: Symbols.dashboard,
                icon: Symbols.dashboard,
                title: 'Home',
              ),
              if (widget.desktopMenuBuilder != null)
                ...widget.desktopMenuBuilder!(context, constraints),
              ...coreDesktopTabBuilder(
                context,
                constraints,
              ),
            ],
            mobileMenu: widget.mobileMenu ?? [],
            views: [
              ...views,
              ...coreDesktopViewBuilder(
                previousItemCount: views.length,
              ),
            ],
            menuWidth: double.tryParse(menuWidth),
          ),
        ),
      ),
    );
  }
}

const _kPlaceholderOffset = 100;

int _v(int value) => _kPlaceholderOffset + value;

List<Widget> coreDesktopViewBuilder({
  required int previousItemCount,
}) {
  // skip previousItemCount to prevent access the wrong index
  final totalPlaceholder = _kPlaceholderOffset - previousItemCount + 1;

  final views = [
    for (int i = 0; i < totalPlaceholder; i++) const SizedBox.shrink(),
    const BookmarkPage(),
    const BlacklistedTagPage(),
    const FavoriteTagsPage(),
    const BulkDownloadPage(),
    const DownloadManagerGatewayPage(),
  ];

  return views;
}

List<Widget> coreDesktopTabBuilder(
  BuildContext context,
  BoxConstraints constraints,
) {
  return [
    const Divider(),
    HomeNavigationTile(
      value: _v(1),
      constraints: constraints,
      selectedIcon: Symbols.bookmark,
      icon: Symbols.bookmark,
      title: 'sideMenu.your_bookmarks'.tr(),
    ),
    HomeNavigationTile(
      value: _v(2),
      constraints: constraints,
      selectedIcon: Symbols.list_alt,
      icon: Symbols.list_alt,
      title: 'sideMenu.your_blacklist'.tr(),
    ),
    HomeNavigationTile(
      value: _v(3),
      constraints: constraints,
      selectedIcon: Symbols.tag,
      icon: Symbols.tag,
      title: 'favorite_tags.favorite_tags'.tr(),
    ),
    HomeNavigationTile(
      value: _v(4),
      constraints: constraints,
      selectedIcon: Symbols.sim_card_download,
      icon: Symbols.sim_card_download,
      title: 'sideMenu.bulk_download'.tr(),
    ),
    HomeNavigationTile(
      value: _v(5),
      constraints: constraints,
      selectedIcon: Symbols.download,
      icon: Symbols.download,
      title: 'Download manager',
    ),
    const Divider(),
    HomeNavigationTile(
      value: 99999,
      constraints: constraints,
      selectedIcon: Symbols.settings,
      icon: Symbols.settings,
      title: 'sideMenu.settings'.tr(),
      onTap: () => goToSettingsPage(context),
    ),
    const SizedBox(height: 8),
  ];
}
