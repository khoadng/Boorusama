// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:multi_split_view/multi_split_view.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/downloads/bulks/bulk_download_page.dart';
import 'package:boorusama/core/downloads/download_manager_page.dart';
import 'package:boorusama/core/favorited_tags/favorited_tags.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/utils/flutter_utils.dart';
import 'package:boorusama/widgets/lazy_indexed_stack.dart';

const double _kDefaultMenuSize = 220;
const String kMenuWidthCacheKey = 'menu_width';

class BooruScope extends ConsumerStatefulWidget {
  const BooruScope({
    super.key,
    required this.config,
    required this.mobileMenuBuilder,
    required this.desktopMenuBuilder,
    required this.desktopViews,
  });

  final BooruConfig config;

  final List<Widget> Function(
    BuildContext context,
    HomePageController controller,
    BoxConstraints constraints,
  ) desktopMenuBuilder;

  final List<Widget> Function(
    BuildContext context,
    HomePageController controller,
  ) mobileMenuBuilder;

  final List<Widget> Function() desktopViews;

  @override
  ConsumerState<BooruScope> createState() => _BooruScopeState();
}

class _BooruScopeState extends ConsumerState<BooruScope> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final controller = HomePageController(scaffoldKey: scaffoldKey);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomePageSidebarKeyboardListener(
      controller: controller,
      child: CustomContextMenuOverlay(
        child: kPreferredLayout.isMobile
            ? OrientationBuilder(
                builder: (context, orientation) => orientation.isPortrait
                    ? _buildMobile()
                    : _buildDesktop(
                        resizable: true,
                        grooveDivider: true,
                      ),
              )
            : _buildDesktop(resizable: true),
      ),
    );
  }

  Widget _buildMobile() {
    final customHome = ref.watchBooruBuilder(ref.watchConfig)?.homeViewBuilder;

    return BooruMobileScope(
      controller: controller,
      config: widget.config,
      menuBuilder: (context, controller) => widget.mobileMenuBuilder(
        context,
        controller,
      ),
      home: customHome != null
          ? customHome(context, widget.config, controller)
          : Scaffold(
              body: Center(
                child: Text('No View found for ${widget.config.name}'),
              ),
            ),
    );
  }

  Widget _buildDesktop({
    bool resizable = false,
    bool grooveDivider = false,
  }) {
    final menuWidth = ref.watch(miscDataProvider(kMenuWidthCacheKey));

    return BooruDesktopScope(
      controller: controller,
      config: widget.config,
      resizable: resizable,
      menuBuilder: (context, constraints) => widget.desktopMenuBuilder(
        context,
        controller,
        constraints,
      ),
      views: widget.desktopViews,
      grooveDivider: grooveDivider,
      menuWidth: double.tryParse(menuWidth),
    );
  }
}

class BooruDesktopScope extends ConsumerStatefulWidget {
  const BooruDesktopScope({
    super.key,
    required this.controller,
    required this.config,
    required this.menuBuilder,
    required this.views,
    this.resizable = false,
    this.grooveDivider = false,
    required this.menuWidth,
  });

  final HomePageController controller;
  final BooruConfig config;
  final List<Widget> Function(BuildContext context, BoxConstraints constraints)
      menuBuilder;

  final List<Widget> Function() views;
  final bool resizable;
  final bool grooveDivider;
  final double? menuWidth;

  @override
  ConsumerState<BooruDesktopScope> createState() => _BooruDesktopScopeState();
}

class _BooruDesktopScopeState extends ConsumerState<BooruDesktopScope> {
  late final MultiSplitViewController splitController;

  @override
  void initState() {
    super.initState();
    splitController = MultiSplitViewController(
      areas: [
        Area(
          id: 'menu',
          data: 'menu',
          min: kMinSideBarWidth,
          max: kMaxSideBarWidth,
          size: widget.menuWidth ?? _kDefaultMenuSize,
        ),
        Area(
          id: 'content',
          data: 'content',
        ),
      ],
    );

    menuWidth.addListener(saveWidthToCache);

    widget.controller.addHandler(_onSidebarStateChanged);
  }

  void _onSidebarStateChanged(open) {
    if (open) {
      _setDefaultSplit();
    } else {
      _setMinSplit();
    }
  }

  void saveWidthToCache() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(miscDataProvider(kMenuWidthCacheKey).notifier)
          .put(menuWidth.value.toString());
    });
  }

  @override
  void dispose() {
    menuWidth.removeListener(saveWidthToCache);
    splitController.dispose();
    menuWidth.dispose();
    widget.controller.removeHandler(_onSidebarStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Builder(
      builder: (context) {
        final views = widget.views();

        return ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, value, child) => LazyIndexedStack(
            index: value,
            children: views,
          ),
        );
      },
    );

    final menu = SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          children: [
            const CurrentBooruTile(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Theme(
                      data: context.theme.copyWith(
                        iconTheme: context.theme.iconTheme.copyWith(size: 20),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: widget.menuBuilder(
                            context,
                            constraints,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: !widget.resizable
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                menu,
                Expanded(
                  child: content,
                )
              ],
            )
          : MultiSplitViewTheme(
              data: MultiSplitViewThemeData(
                dividerThickness: widget.grooveDivider
                    ? Screen.of(context).size.isLarge
                        ? 24
                        : 16
                    : 4,
                dividerPainter: !widget.grooveDivider
                    ? DividerPainters.background(
                        animationEnabled: false,
                        color: context.colorScheme.surface,
                        highlightedColor: context.colorScheme.primary,
                      )
                    : DividerPainters.grooved1(
                        animationDuration: const Duration(milliseconds: 150),
                        color: context.colorScheme.onSurface,
                        thickness: Screen.of(context).size.isLarge ? 6 : 3,
                        size: 75,
                        highlightedColor: context.colorScheme.primary,
                      ),
              ),
              child: MultiSplitView(
                controller: splitController,
                onDividerDoubleTap: (divider) {
                  setState(() {
                    final width = menuWidth.value;

                    if (width == kMinSideBarWidth) {
                      _setDefaultSplit();
                    } else if (width <= _kDefaultMenuSize) {
                      _setMinSplit();
                    } else {
                      _setDefaultSplit();
                    }
                  });
                },
                builder: (context, area) => switch (area.data) {
                  'menu' => LayoutBuilder(
                      builder: (_, c) {
                        // no need to set state here, just a quick hack to get the current width of the menu
                        menuWidth.value = c.maxWidth;

                        return menu;
                      },
                    ),
                  'content' => content,
                  _ => const SizedBox(),
                },
              ),
            ),
    );
  }

  void _setMinSplit() {
    splitController.areas = [
      Area(
        id: 'menu',
        data: 'menu',
        min: kMinSideBarWidth,
        max: kMaxSideBarWidth,
        size: kMinSideBarWidth,
      ),
      Area(
        id: 'content',
        data: 'content',
      ),
    ];
  }

  void _setDefaultSplit() {
    splitController.areas = [
      Area(
        id: 'menu',
        data: 'menu',
        min: kMinSideBarWidth,
        max: kMaxSideBarWidth,
        size: _kDefaultMenuSize,
      ),
      Area(
        id: 'content',
        data: 'content',
      ),
    ];
  }

  late final menuWidth = ValueNotifier(widget.menuWidth ?? _kDefaultMenuSize);
}

class BooruMobileScope extends ConsumerWidget {
  const BooruMobileScope({
    super.key,
    required this.controller,
    required this.config,
    required this.menuBuilder,
    required this.home,
  });

  final HomePageController controller;
  final BooruConfig config;
  final Widget home;
  final List<Widget> Function(
      BuildContext context, HomePageController controller) menuBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only used to force rebuild when language changes
    ref.watch(settingsProvider.select((value) => value.language));
    final booruConfigSelectorPosition = ref.watch(
        settingsProvider.select((value) => value.booruConfigSelectorPosition));
    final swipeArea = ref.watch(settingsProvider
        .select((value) => value.swipeAreaToOpenSidebarPercentage));
    final hideLabel = ref
        .watch(settingsProvider.select((value) => value.hideBooruConfigLabel));

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarBrightness:
            context.themeMode.isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness:
            context.themeMode.isLight ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawerEdgeDragWidth: _calculateDrawerEdgeDragWidth(context, swipeArea),
        key: controller.scaffoldKey,
        bottomNavigationBar:
            booruConfigSelectorPosition == BooruConfigSelectorPosition.bottom
                ? Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom,
                    ),
                    height: (kBottomNavigationBarHeight - (hideLabel ? 4 : -8)),
                    child: const BooruSelector(
                      direction: Axis.horizontal,
                    ),
                  )
                : null,
        drawer: SideBarMenu(
          width: 300,
          popOnSelect: true,
          padding: EdgeInsets.zero,
          initialContentBuilder: (context) => menuBuilder(context, controller),
        ),
        body: Column(
          children: [
            const NetworkUnavailableIndicatorWithState(),
            Expanded(
              child: home,
            ),
          ],
        ),
      ),
    );
  }
}

double _calculateDrawerEdgeDragWidth(BuildContext context, int areaPercentage) {
  final minValue = 20 + MediaQuery.paddingOf(context).left;
  final screenWidth = context.screenWidth;
  final value = (areaPercentage / 100).clamp(0.05, 1);
  final width = screenWidth * value;

  // if the width is less than the minimum value, return the minimum value
  return width < minValue ? minValue : width;
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
  HomePageController controller,
) {
  return [
    const Divider(),
    HomeNavigationTile(
      value: _v(1),
      controller: controller,
      constraints: constraints,
      selectedIcon: Symbols.bookmark,
      icon: Symbols.bookmark,
      title: 'sideMenu.your_bookmarks'.tr(),
    ),
    HomeNavigationTile(
      value: _v(2),
      controller: controller,
      constraints: constraints,
      selectedIcon: Symbols.list_alt,
      icon: Symbols.list_alt,
      title: 'sideMenu.your_blacklist'.tr(),
    ),
    HomeNavigationTile(
      value: _v(3),
      controller: controller,
      constraints: constraints,
      selectedIcon: Symbols.tag,
      icon: Symbols.tag,
      title: 'favorite_tags.favorite_tags'.tr(),
    ),
    HomeNavigationTile(
      value: _v(4),
      controller: controller,
      constraints: constraints,
      selectedIcon: Symbols.sim_card_download,
      icon: Symbols.sim_card_download,
      title: 'sideMenu.bulk_download'.tr(),
    ),
    HomeNavigationTile(
      value: _v(5),
      controller: controller,
      constraints: constraints,
      selectedIcon: Symbols.download,
      icon: Symbols.download,
      title: 'Download manager',
    ),
    const Divider(),
    HomeNavigationTile(
      value: 99999,
      controller: controller,
      constraints: constraints,
      selectedIcon: Symbols.settings,
      icon: Symbols.settings,
      title: 'sideMenu.settings'.tr(),
      onTap: () => context.go('/settings'),
    ),
    const SizedBox(height: 8),
  ];
}
