// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';

// Project imports:
import 'package:boorusama/app.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/manage.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/settings.dart';
import 'package:boorusama/core/settings/data.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/lazy_indexed_stack.dart';

const double _kDefaultMenuSize = 220;

class BooruDesktopScope extends ConsumerStatefulWidget {
  const BooruDesktopScope({
    super.key,
    required this.controller,
    required this.menuBuilder,
    required this.mobileMenu,
    required this.views,
    required this.menuWidth,
  });

  final HomePageController controller;
  final List<Widget> Function(BuildContext context, BoxConstraints constraints)
      menuBuilder;

  final List<Widget> views;
  final double? menuWidth;

  final List<Widget> mobileMenu;

  @override
  ConsumerState<BooruDesktopScope> createState() => _BooruDesktopScopeState();
}

class _BooruDesktopScopeState extends ConsumerState<BooruDesktopScope> {
  late MultiSplitViewController splitController;

  bool get isDesktop => context.isLargeScreen;

  @override
  void initState() {
    super.initState();

    menuWidth.addListener(saveWidthToCache);

    widget.controller.addHandler(_onSidebarStateChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    splitController = MultiSplitViewController(
      areas: [
        if (isDesktop)
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
  }

  void _onSidebarStateChanged(open) {
    if (!isDesktop) return;

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
    final content = ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, child) => MediaQuery.removePadding(
        context: context,
        removeLeft: true,
        child: LazyIndexedStack(
          index: value,
          children: widget.views,
        ),
      ),
    );

    final menu = isDesktop
        ? SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLow,
                border: Border(
                  right: BorderSide(
                    color: context.colorScheme.hintColor,
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
                          data: context.theme.copyWith(
                            iconTheme:
                                context.theme.iconTheme.copyWith(size: 20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              ...widget.menuBuilder(
                                context,
                                constraints,
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
        : const SizedBox();

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
        statusBarBrightness: context.brightness,
        statusBarIconBrightness: context.onBrightness,
      ),
      child: Scaffold(
        key: widget.controller.scaffoldKey,
        bottomNavigationBar: !isDesktop &&
                booruConfigSelectorPosition ==
                    BooruConfigSelectorPosition.bottom
            ? Container(
                color: Colors.transparent,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom,
                ),
                height: kBottomNavigationBarHeight - (hideLabel ? 4 : -8),
                child: const BooruSelector(
                  direction: Axis.horizontal,
                ),
              )
            : null,
        drawer: !isDesktop
            ? SideBarMenu(
                width: 300,
                popOnSelect: true,
                padding: EdgeInsets.zero,
                initialContent: widget.mobileMenu,
              )
            : null,
        backgroundColor: context.colorScheme.surface,
        resizeToAvoidBottomInset: !isDesktop ? false : null,
        drawerEdgeDragWidth: _calculateDrawerEdgeDragWidth(context, swipeArea),
        body: MultiSplitViewTheme(
          data: MultiSplitViewThemeData(
            dividerThickness: !isDesktopPlatform()
                ? Screen.of(context).size.isLarge
                    ? 24
                    : 16
                : 4,
            dividerPainter: isDesktopPlatform()
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
          child: Column(
            children: [
              const NetworkUnavailableIndicatorWithState(),
              Expanded(
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
                    builder: (context, area) => isDesktop
                        ? switch (area.data) {
                            'menu' => LayoutBuilder(
                                builder: (_, c) {
                                  // no need to set state here, just a quick hack to get the current width of the menu
                                  menuWidth.value = c.maxWidth;

                                  return menu;
                                },
                              ),
                            'content' => content,
                            _ => const SizedBox(),
                          }
                        : switch (area.data) {
                            'content' => content,
                            _ => const SizedBox(),
                          }),
              ),
            ],
          ),
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

double _calculateDrawerEdgeDragWidth(BuildContext context, int areaPercentage) {
  final minValue = 20 + MediaQuery.paddingOf(context).left;
  final screenWidth = context.screenWidth;
  final value = (areaPercentage / 100).clamp(0.05, 1);
  final width = screenWidth * value;

  // if the width is less than the minimum value, return the minimum value
  return width < minValue ? minValue : width;
}
