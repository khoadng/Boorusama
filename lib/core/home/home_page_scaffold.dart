// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../foundation/boot/providers.dart';
import '../../foundation/display.dart';
import '../blacklists/widgets.dart';
import '../bookmarks/widgets.dart';
import '../boorus/engine/providers.dart';
import '../bulk_downloads/widgets.dart';
import '../cache/providers.dart';
import '../configs/manage/widgets.dart';
import '../configs/ref.dart';
import '../donate/routes.dart';
import '../download_manager/widgets.dart';
import '../premiums/premiums.dart';
import '../premiums/providers.dart';
import '../premiums/routes.dart';
import '../search/search/src/pages/search_page.dart';
import '../settings/routes.dart';
import '../tags/favorites/widgets.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'booru_scope.dart';
import 'constants.dart';
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
  )?
  desktopMenuBuilder;

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
      builder: (context, value, child) => Column(
        children: [
          if (!context.isLargeScreen && value > 0)
            SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  BackButton(
                    onPressed: () => controller.goToTab(0),
                  ),
                ],
              ),
            ),
          Expanded(
            child: LazyIndexedStack(
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
        ],
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
  )?
  desktopMenuBuilder;

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
                  const CurrentBooruTile(minWidth: kMinSideBarWidth),
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
                                title: context.t.sideMenu.home,
                              ),
                              if (desktopMenuBuilder != null)
                                ...desktopMenuBuilder!(
                                  context,
                                  constraints,
                                ),
                              ...coreDesktopTabBuilder(
                                ref,
                                constraints,
                                viewKey,
                                ref.watch(hasPremiumProvider),
                                ref.watch(showPremiumFeatsProvider),
                                ref.watch(isFossBuildProvider),
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
    final customHome = ref
        .watch(booruBuilderProvider(ref.watchConfigAuth))
        ?.homeViewBuilder;

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
  final totalPlaceholder =
      _kPlaceholderOffset -
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
  WidgetRef ref,
  BoxConstraints constraints,
  CustomHomeViewKey? viewKey,
  bool hasPremium,
  bool showPremium,
  bool isFossBuild,
) {
  final context = ref.context;
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
      title: context.t.sideMenu.your_bookmarks,
    ),
    HomeNavigationTile(
      value: _v(3),
      constraints: constraints,
      selectedIcon: Symbols.list_alt,
      icon: Symbols.list_alt,
      title: context.t.sideMenu.your_blacklist,
    ),
    HomeNavigationTile(
      value: _v(4),
      constraints: constraints,
      selectedIcon: Symbols.tag,
      icon: Symbols.tag,
      title: context.t.favorite_tags.favorite_tags,
    ),
    HomeNavigationTile(
      value: _v(5),
      constraints: constraints,
      selectedIcon: Symbols.sim_card_download,
      icon: Symbols.sim_card_download,
      title: context.t.sideMenu.bulk_download,
    ),
    HomeNavigationTile(
      value: _v(6),
      constraints: constraints,
      selectedIcon: Symbols.download,
      icon: Symbols.download,
      title: context.t.sideMenu.download_manager,
    ),
    const Divider(),
    if (isFossBuild)
      HomeNavigationTile(
        value: 99998,
        constraints: constraints,
        selectedIcon: Symbols.favorite,
        icon: Symbols.favorite,
        title: context.t.donation.donate,
        onTap: () => goToDonationPage(ref),
        forceFillIcon: true,
        forceIconColor: Colors.red,
      )
    else if (showPremium && !kForcePremium && !hasPremium)
      HomeNavigationTile(
        value: 99998,
        constraints: constraints,
        selectedIcon: Symbols.favorite,
        icon: Symbols.favorite,
        title: context.t.premium.get_premium(brand: kPremiumBrandName),
        onTap: () => goToPremiumPage(ref),
        forceFillIcon: true,
        forceIconColor: Colors.red,
      ),
    HomeNavigationTile(
      value: 99999,
      constraints: constraints,
      selectedIcon: Symbols.settings,
      icon: Symbols.settings,
      title: context.t.sideMenu.settings,
      onTap: () => goToSettingsPage(ref),
    ),
    const SizedBox(height: 8),
  ];
}
