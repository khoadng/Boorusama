// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:multi_split_view/multi_split_view.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/entry_page.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/blacklists/blacklisted_tag_page.dart';
import 'package:boorusama/core/pages/bookmarks/bookmark_page.dart';
import 'package:boorusama/core/pages/downloads/bulk_download_page.dart';
import 'package:boorusama/core/pages/favorite_tags/favorite_tags_page.dart';
import 'package:boorusama/core/pages/home/side_bar_menu.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/lazy_indexed_stack.dart';

class BooruScope extends ConsumerStatefulWidget {
  const BooruScope({
    super.key,
    required this.config,
    required this.mobileMenuBuilder,
    required this.desktopMenuBuilder,
    required this.desktopViews,
    required this.mobileView,
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
  final Widget Function(HomePageController controller) mobileView;

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
    return CustomContextMenuOverlay(
      child: isMobilePlatform()
          ? OrientationBuilder(
              builder: (context, orientation) => orientation.isPortrait
                  ? _buildMobile()
                  : _buildDesktop(
                      resizable: true,
                      grooveDivider: true,
                    ),
            )
          : _buildDesktop(resizable: true),
    );
  }

  Widget _buildMobile() {
    return BooruMobileScope(
      controller: controller,
      config: widget.config,
      menuBuilder: (context, controller) => widget.mobileMenuBuilder(
        context,
        controller,
      ),
      home: widget.mobileView(controller),
    );
  }

  Widget _buildDesktop({
    bool resizable = false,
    bool grooveDivider = false,
  }) {
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
  });

  final HomePageController controller;
  final BooruConfig config;
  final List<Widget> Function(BuildContext context, BoxConstraints constraints)
      menuBuilder;

  final List<Widget> Function() views;
  final bool resizable;
  final bool grooveDivider;

  @override
  ConsumerState<BooruDesktopScope> createState() => _BooruDesktopScopeState();
}

class _BooruDesktopScopeState extends ConsumerState<BooruDesktopScope> {
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
        width: 220,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceVariant,
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
                dividerThickness: 4,
                dividerPainter: !widget.grooveDivider
                    ? DividerPainters.background(
                        animationEnabled: false,
                        color: context.colorScheme.surface,
                        highlightedColor: context.colorScheme.primary,
                      )
                    : DividerPainters.grooved1(
                        color: context.colorScheme.onSurface,
                        thickness: 4,
                        size: 75,
                        highlightedSize: 40,
                        highlightedColor: context.colorScheme.primary,
                      ),
              ),
              child: MultiSplitView(
                axis: Axis.horizontal,
                initialAreas: [
                  Area(
                    minimalSize: kMinSideBarWidth,
                    size: 280,
                  ),
                  Area(
                    minimalSize: 500,
                  ),
                ],
                children: [
                  menu,
                  content,
                ],
              ),
            ),
    );
  }
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
        key: controller.scaffoldKey,
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
      title: 'Favorite tags',
    ),
    HomeNavigationTile(
      value: _v(4),
      controller: controller,
      constraints: constraints,
      selectedIcon: Symbols.download,
      icon: Symbols.download,
      title: 'sideMenu.bulk_download'.tr(),
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
  ];
}
