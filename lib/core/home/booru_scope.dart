// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';

// Project imports:
import '../app.dart';
import '../cache/providers.dart';
import '../configs/widgets.dart';
import '../foundation/display.dart';
import '../foundation/platform.dart';
import '../settings/providers.dart';
import '../settings/settings.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'home_page_controller.dart';
import 'side_bar_menu.dart';

const double _kDefaultMenuSize = 220;
const String kMenuWidthCacheKey = 'menu_width';

class BooruScope extends ConsumerStatefulWidget {
  const BooruScope({
    required this.controller,
    required this.menu,
    required this.content,
    required this.mobileMenu,
    required this.menuWidth,
    super.key,
  });

  final HomePageController controller;
  final Widget menu;
  final Widget content;

  final double? menuWidth;

  final List<Widget> mobileMenu;

  @override
  ConsumerState<BooruScope> createState() => _BooruScopeState();
}

class _BooruScopeState extends ConsumerState<BooruScope> {
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
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final swipeArea = ref.watch(
      settingsProvider
          .select((value) => value.swipeAreaToOpenSidebarPercentage),
    );

    final position = ref.watch(
      settingsProvider.select((value) => value.booruConfigSelectorPosition),
    );

    return AnnotatedRegion(
      // Needed to make the bottom navigation bar transparent
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarBrightness: theme.brightness,
        statusBarIconBrightness: context.onBrightness,
      ),
      child: Scaffold(
        key: widget.controller.scaffoldKey,
        bottomNavigationBar:
            !isDesktop && position == BooruConfigSelectorPosition.bottom
                ? const BooruSelectorWithBottomPadding()
                : null,
        drawer: !isDesktop
            ? SideBarMenu(
                width: 300,
                padding: EdgeInsets.zero,
                initialContent: widget.mobileMenu,
              )
            : null,
        backgroundColor: colorScheme.surface,
        resizeToAvoidBottomInset: false,
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
                    color: colorScheme.surface,
                    highlightedColor: colorScheme.primary,
                  )
                : DividerPainters.grooved1(
                    animationDuration: const Duration(milliseconds: 150),
                    color: colorScheme.onSurface,
                    thickness: Screen.of(context).size.isLarge ? 6 : 3,
                    size: 75,
                    highlightedColor: colorScheme.primary,
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

                                return widget.menu;
                              },
                            ),
                          'content' => widget.content,
                          _ => const SizedBox.shrink(),
                        }
                      : switch (area.data) {
                          'content' => widget.content,
                          _ => const SizedBox.shrink(),
                        },
                ),
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

class BooruSelectorWithBottomPadding extends ConsumerWidget {
  const BooruSelectorWithBottomPadding({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideLabel = ref
        .watch(settingsProvider.select((value) => value.hideBooruConfigLabel));

    return Container(
      color: Colors.transparent,
      height: kBottomNavigationBarHeight - (hideLabel ? 4 : -8),
      margin: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      child: const BooruSelector(
        direction: Axis.horizontal,
      ),
    );
  }
}

double? _calculateDrawerEdgeDragWidth(
  BuildContext context,
  int areaPercentage,
) {
  const minValue = 20.0;
  final screenWidth = MediaQuery.sizeOf(context).width;
  final value = (areaPercentage / 100).clamp(0.05, 1);
  final width = screenWidth * value;

  // if the width is less than the minimum value, return the minimum value
  return width < minValue ? minValue : width;
}
