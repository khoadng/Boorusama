// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../blacklists/widgets.dart';
import '../bookmarks/widgets.dart';
import '../boorus/engine/providers.dart';
import '../cache/providers.dart';
import '../configs/widgets.dart';
import '../downloads/bulks.dart';
import '../downloads/manager.dart';
import '../foundation/display.dart';
import '../premiums/premiums.dart';
import '../premiums/providers.dart';
import '../premiums/routes.dart';
import '../search/search/src/pages/search_page.dart';
import '../settings/routes.dart';
import '../tags/favorites/widgets.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'booru_scope.dart';
import 'custom_home.dart';
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
    return InheritedHomePageController(
      controller: controller,
      child: HomePageSidebarKeyboardListener(
        controller: controller,
        child: CustomContextMenuOverlay(
          child: Builder(
            builder: (context) {
              final menuWidth = ref.watch(miscDataProvider(kMenuWidthCacheKey));

              return BooruScope(
                controller: controller,
                menu: HomeSideMenu(
                  desktopMenuBuilder: widget.desktopMenuBuilder,
                ),
                content: HomeContent(
                  desktopViews: widget.desktopViews,
                ),
                mobileMenu: widget.mobileMenu ?? [],
                menuWidth: double.tryParse(menuWidth),
              );
            },
          ),
        ),
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({
    required this.desktopViews,
    super.key,
  });

  final List<Widget>? desktopViews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = InheritedHomePageController.of(context);

    final homeViewKey = ref.watch(customHomeViewKeyProvider);

    final views = [
      const CustomHomePage(),
      if (desktopViews != null) ...desktopViews!,
    ];

    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: !context.isLargeScreen && value > 0
            ? AppBar(
                leading: BackButton(
                  onPressed: () {
                    controller.goToTab(0);
                  },
                ),
              )
            : null,
        body: LazyIndexedStack(
          index: value,
          children: [
            ...views,
            ...coreDesktopViewBuilder(
              previousItemCount: views.length,
              viewKey: homeViewKey,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSideMenu extends ConsumerWidget {
  const HomeSideMenu({
    required this.desktopMenuBuilder,
    super.key,
  });

  final List<Widget> Function(
    BuildContext context,
    BoxConstraints constraints,
  )? desktopMenuBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final viewKey = ref.watch(customHomeViewKeyProvider);

    return context.isLargeScreen
        ? SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                border: Border(
                  right: BorderSide(
                    color: colorScheme.hintColor,
                    width: 0.25,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const CurrentBooruTile(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (_, constraints) => SingleChildScrollView(
                        child: Theme(
                          data: theme.copyWith(
                            iconTheme: theme.iconTheme.copyWith(size: 20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              HomeNavigationTile(
                                value: 0,
                                constraints: constraints,
                                selectedIcon: Symbols.dashboard,
                                icon: Symbols.dashboard,
                                title: 'Home',
                              ),
                              if (desktopMenuBuilder != null)
                                ...desktopMenuBuilder!(
                                  context,
                                  constraints,
                                ),
                              ...coreDesktopTabBuilder(
                                context,
                                constraints,
                                viewKey,
                                ref.watch(hasPremiumProvider),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}

class CustomHomePage extends ConsumerWidget {
  const CustomHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customHome = ref.watch(currentBooruBuilderProvider)?.homeViewBuilder;

    return customHome != null
        ? customHome(context)
        : const Scaffold(
            body: Center(child: Text('No home view builder found')),
          );
  }
}

const _kPlaceholderOffset = 100;

int _v(int value) => _kPlaceholderOffset + value;

List<Widget> coreDesktopViewBuilder({
  required int previousItemCount,
  required CustomHomeViewKey? viewKey,
}) {
  // skip previousItemCount to prevent access the wrong index
  final totalPlaceholder = _kPlaceholderOffset -
      previousItemCount +
      (viewKey != null && viewKey.isAlt ? 1 : 2);

  final views = [
    for (int i = 0; i < totalPlaceholder; i++) const SizedBox.shrink(),
    if (viewKey != null && viewKey.isAlt) const SearchPage(),
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
  CustomHomeViewKey? viewKey,
  bool hasPremium,
) {
  return [
    const Divider(),
    if (viewKey != null && viewKey.isAlt)
      HomeNavigationTile(
        value: _v(1),
        constraints: constraints,
        selectedIcon: Symbols.search,
        icon: Symbols.search,
        title: 'Search',
      ),
    HomeNavigationTile(
      value: _v(2),
      constraints: constraints,
      selectedIcon: Symbols.bookmark,
      icon: Symbols.bookmark,
      title: 'sideMenu.your_bookmarks'.tr(),
    ),
    HomeNavigationTile(
      value: _v(3),
      constraints: constraints,
      selectedIcon: Symbols.list_alt,
      icon: Symbols.list_alt,
      title: 'sideMenu.your_blacklist'.tr(),
    ),
    HomeNavigationTile(
      value: _v(4),
      constraints: constraints,
      selectedIcon: Symbols.tag,
      icon: Symbols.tag,
      title: 'favorite_tags.favorite_tags'.tr(),
    ),
    HomeNavigationTile(
      value: _v(5),
      constraints: constraints,
      selectedIcon: Symbols.sim_card_download,
      icon: Symbols.sim_card_download,
      title: 'sideMenu.bulk_download'.tr(),
    ),
    HomeNavigationTile(
      value: _v(6),
      constraints: constraints,
      selectedIcon: Symbols.download,
      icon: Symbols.download,
      title: 'Download manager',
    ),
    const Divider(),
    if (kPremiumEnabled && !kForcePremium && !hasPremium)
      HomeNavigationTile(
        value: 99998,
        constraints: constraints,
        selectedIcon: Symbols.favorite,
        icon: Symbols.favorite,
        title: 'Get $kPremiumBrandName',
        onTap: () => goToPremiumPage(context),
        forceFillIcon: true,
        forceIconColor: Colors.red,
      ),
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
