// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/favorited_tags/favorited_tags.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';
import 'booru_desktop_scope.dart';

const String kMenuWidthCacheKey = 'menu_width';

class BooruScope extends ConsumerStatefulWidget {
  const BooruScope({
    super.key,
    required this.config,
    required this.mobileMenu,
    required this.desktopMenuBuilder,
    required this.desktopViews,
    this.controller,
  });

  final BooruConfig config;

  final List<Widget> Function(
    BuildContext context,
    HomePageController controller,
    BoxConstraints constraints,
  ) desktopMenuBuilder;

  final List<Widget> mobileMenu;

  final List<Widget> desktopViews;

  final HomePageController? controller;

  @override
  ConsumerState<BooruScope> createState() => _BooruScopeState();
}

class _BooruScopeState extends ConsumerState<BooruScope> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final controller =
      widget.controller ?? HomePageController(scaffoldKey: scaffoldKey);

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuWidth = ref.watch(miscDataProvider(kMenuWidthCacheKey));
    final desktopViews = widget.desktopViews
        .mapIndexed((i, e) => Scaffold(
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
            ))
        .toList();

    return HomePageSidebarKeyboardListener(
      controller: controller,
      child: CustomContextMenuOverlay(
        child: BooruDesktopScope(
          controller: controller,
          config: widget.config,
          menuBuilder: (context, constraints) => widget.desktopMenuBuilder(
            context,
            controller,
            constraints,
          ),
          mobileMenu: widget.mobileMenu,
          views: desktopViews,
          menuWidth: double.tryParse(menuWidth),
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
