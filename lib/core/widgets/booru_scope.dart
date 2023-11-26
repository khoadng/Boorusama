// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/entry_page.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/home/side_bar_menu.dart';
import 'package:boorusama/core/widgets/custom_context_menu_overlay.dart';
import 'package:boorusama/core/widgets/network_indicator_with_state.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/lazy_indexed_stack.dart';
import 'package:boorusama/widgets/split.dart';
import 'current_booru_tile.dart';

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

  final List<Widget> desktopViews;
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
              builder: (context, orientation) =>
                  orientation.isPortrait ? _buildMobile() : _buildDesktop(),
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

  Widget _buildDesktop({bool resizable = false}) {
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
  });

  final HomePageController controller;
  final BooruConfig config;
  final List<Widget> Function(BuildContext context, BoxConstraints constraints)
      menuBuilder;

  final List<Widget> views;
  final bool resizable;

  @override
  ConsumerState<BooruDesktopScope> createState() => _BooruDesktopScopeState();
}

class _BooruDesktopScopeState extends ConsumerState<BooruDesktopScope> {
  @override
  Widget build(BuildContext context) {
    final content = ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, child) => LazyIndexedStack(
        index: value,
        children: widget.views,
      ),
    );

    final menu = Container(
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
          : Split(
              axis: Axis.horizontal,
              minSizes: const [55, 600],
              initialFractions: const [0.18, 0.82],
              children: [
                menu,
                content,
              ],
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
