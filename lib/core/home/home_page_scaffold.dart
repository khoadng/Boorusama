// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../boorus/providers.dart';
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
    HomePageController controller,
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

    final views = [
      if (customHome != null)
        customHome(context, controller)
      else
        const Scaffold(
          body: Center(child: Text('No home view builder found')),
        ),
      if (widget.desktopViews != null) ...widget.desktopViews!,
    ];

    return BooruScope(
      controller: controller,
      mobileMenu: widget.mobileMenu ?? [],
      desktopMenuBuilder: (context, controller, constraints) => [
        HomeNavigationTile(
          value: 0,
          controller: controller,
          constraints: constraints,
          selectedIcon: Symbols.dashboard,
          icon: Symbols.dashboard,
          title: 'Home',
        ),
        if (widget.desktopMenuBuilder != null)
          ...widget.desktopMenuBuilder!(context, controller, constraints),
        ...coreDesktopTabBuilder(
          context,
          constraints,
          controller,
        ),
      ],
      desktopViews: [
        ...views,
        ...coreDesktopViewBuilder(
          previousItemCount: views.length,
        ),
      ],
    );
  }
}
