// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../../foundation/keyboard.dart';
import '../../../../settings/settings.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/post.dart';
import '../utils/conditional_value_listenable_builder.dart';
import '../widgets/post_controller_event_listener.dart';
import '../widgets/post_grid_controller.dart';
import 'highres_preview_on_mobile_data_warning_banner.dart';
import 'swipe_to.dart';
import 'too_much_cached_images_warning_banner.dart';

class RawPostGrid<T extends Post> extends StatefulWidget {
  const RawPostGrid({
    required this.gridHeader,
    required this.topPageIndicator,
    required this.bottomPageIndicator,
    required this.body,
    required this.controller,
    required this.onNextPage,
    required this.onPreviousPage,
    super.key,
    this.onLoadMore,
    this.onRefresh,
    this.sliverHeaders,
    this.scrollController,
    this.footer,
    this.header,
    this.blacklistedIdString,
    this.multiSelectController,
    this.refreshAtStart = true,
    this.enablePullToRefresh = true,
    this.safeArea = true,
  });

  final VoidCallback? onLoadMore;
  final void Function()? onRefresh;
  final void Function() onNextPage;
  final void Function() onPreviousPage;
  final List<Widget>? sliverHeaders;
  final AutoScrollController? scrollController;

  final bool refreshAtStart;
  final bool enablePullToRefresh;
  final bool safeArea;

  final Widget? footer;
  final Widget? header;
  final Widget body;
  final Widget gridHeader;
  final Widget topPageIndicator;
  final Widget bottomPageIndicator;

  final String? blacklistedIdString;

  final MultiSelectController<T>? multiSelectController;

  final PostGridController<T> controller;

  @override
  State<RawPostGrid<T>> createState() => _RawPostGridState();
}

class _RawPostGridState<T extends Post> extends State<RawPostGrid<T>>
    with TickerProviderStateMixin, KeyboardListenerMixin {
  late final AutoScrollController _autoScrollController;
  late final MultiSelectController<T> _multiSelectController;

  PostGridController<T> get controller => widget.controller;

  var hasMore = true;
  final loading = ValueNotifier(false);
  final refreshing = ValueNotifier(false);
  var items = <T>[];
  late var pageMode = controller.pageMode;

  @override
  void initState() {
    super.initState();
    _autoScrollController = widget.scrollController ?? AutoScrollController();
    _multiSelectController =
        widget.multiSelectController ?? MultiSelectController<T>();

    controller.addListener(_onControllerChange);
    if (widget.refreshAtStart) {
      controller.refresh();
    }

    registerListener(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (isKeyPressed(LogicalKeyboardKey.f5, event: event)) {
      widget.onRefresh?.call();
      controller.refresh();
    }

    return false;
  }

  @override
  void dispose() {
    removeListener(_handleKeyEvent);

    if (widget.scrollController == null) {
      _autoScrollController.dispose();
    }

    if (widget.multiSelectController == null) {
      _multiSelectController.dispose();
    }

    widget.controller.removeListener(_onControllerChange);

    super.dispose();
  }

  void _onControllerChange() {
    if (!mounted) return;

    // check if refreshing, don't set state if it is
    if (controller.refreshing) {
      refreshing.value = true;

      // reset multi select if something is selected
      if (_multiSelectController.selectedItems.isNotEmpty) {
        _multiSelectController.clearSelected();
      }

      return;
    }

    // check if loading, don't set state if it is
    if (controller.loading) {
      loading.value = true;
      return;
    }

    setState(() {
      items = controller.items.toList();
      hasMore = controller.hasMore;
      loading.value = controller.loading;
      refreshing.value = controller.refreshing;
      pageMode = controller.pageMode;
    });
  }

  void _onScrollToTop() {
    _autoScrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surface,
      child: ConditionalParentWidget(
        condition: widget.safeArea,
        conditionalBuilder: (child) => SafeArea(
          bottom: false,
          left: false,
          child: child,
        ),
        child: MultiSelectWidget<T>(
          footer: widget.footer,
          multiSelectController: _multiSelectController,
          header: widget.header != null
              ? widget.header!
              : AppBar(
                  leading: IconButton(
                    onPressed: () =>
                        _multiSelectController.disableMultiSelect(),
                    icon: const Icon(Symbols.close),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => _multiSelectController.selectAll(items),
                      icon: const Icon(Symbols.select_all),
                    ),
                    IconButton(
                      onPressed: _multiSelectController.clearSelected,
                      icon: const Icon(Symbols.clear_all),
                    ),
                  ],
                  title: ValueListenableBuilder(
                    valueListenable:
                        _multiSelectController.selectedItemsNotifier,
                    builder: (_, selected, __) => selected.isEmpty
                        ? const Text('Select items')
                        : Text('${selected.length} Items selected'),
                  ),
                ),
          child: Scaffold(
            floatingActionButton: ValueListenableBuilder(
              valueListenable: _multiSelectController.multiSelectNotifier,
              builder: (_, multiSelect, __) => Padding(
                padding: multiSelect
                    ? const EdgeInsets.only(bottom: 48)
                    : EdgeInsets.zero,
                child: ScrollToTop(
                  scrollController: _autoScrollController,
                  onBottomReached: () {
                    if (controller.pageMode == PageMode.infinite && hasMore) {
                      widget.onLoadMore?.call();
                      controller.fetchMore();
                    }
                  },
                  child: BooruScrollToTopButton(
                    onPressed: _onScrollToTop,
                  ),
                ),
              ),
            ),
            body: ConditionalParentWidget(
              condition: kPreferredLayout.isMobile,
              conditionalBuilder: (child) => RefreshIndicator(
                edgeOffset: 60,
                displacement: 50,
                notificationPredicate:
                    widget.enablePullToRefresh ? (_) => true : (_) => false,
                onRefresh: () async {
                  widget.onRefresh?.call();
                  _multiSelectController.clearSelected();
                  await controller.refresh(
                    maintainPage: true,
                  );
                },
                child: child,
              ),
              child: ImprovedScrolling(
                scrollController: _autoScrollController,
                // https://github.com/adrianflutur/flutter_improved_scrolling/issues/5
                // ignore: avoid_redundant_argument_values
                enableKeyboardScrolling: false,
                enableMMBScrolling: true,
                child: ConditionalParentWidget(
                  // Should remove this later
                  condition: true,
                  conditionalBuilder: (child) => ValueListenableBuilder(
                    valueListenable: refreshing,
                    builder: (_, refreshing, __) =>
                        _buildPaginatedSwipe(child, refreshing),
                  ),
                  child: _CustomScrollView(
                    controller: _autoScrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: ValueListenableBuilder(
                          valueListenable:
                              _multiSelectController.multiSelectNotifier,
                          builder: (_, multiSelect, __) => PopScope(
                            canPop: !multiSelect,
                            onPopInvokedWithResult: (didPop, _) {
                              if (didPop) return;
                              if (multiSelect) {
                                _multiSelectController.disableMultiSelect();
                              }
                            },
                            child: const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      if (widget.sliverHeaders != null)
                        ...widget.sliverHeaders!.map(
                          (e) => ValueListenableBuilder(
                            valueListenable:
                                _multiSelectController.multiSelectNotifier,
                            builder: (_, multiSelect, __) => SliverOffstage(
                              offstage: multiSelect,
                              sliver: e,
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: PostControllerEventListener(
                          controller: controller,
                          onEvent: (event) {
                            if (event is PostControllerRefreshStarted) {
                              context.contextMenuOverlay.hide();
                            }
                          },
                          child: const SizedBox.shrink(),
                        ),
                      ),
                      ConditionalValueListenableBuilder(
                        valueListenable: refreshing,
                        useFalseChildAsCache: true,
                        trueChild: const SliverSizedBox.shrink(),
                        falseChild: SliverPinnedHeader(
                          child: widget.gridHeader,
                        ),
                      ),
                      ConditionalValueListenableBuilder(
                        valueListenable: refreshing,
                        useFalseChildAsCache: true,
                        trueChild: const SliverSizedBox.shrink(),
                        falseChild: const SliverToBoxAdapter(
                          child: HighresPreviewOnMobileDataWarningBanner(),
                        ),
                      ),
                      ConditionalValueListenableBuilder(
                        valueListenable: refreshing,
                        useFalseChildAsCache: true,
                        trueChild: const SliverSizedBox.shrink(),
                        falseChild: const SliverToBoxAdapter(
                          child: TooMuchCachedImagesWarningBanner(
                            threshold: _kImageCacheThreshold,
                          ),
                        ),
                      ),
                      if (pageMode == PageMode.paginated)
                        ConditionalValueListenableBuilder(
                          valueListenable: refreshing,
                          useFalseChildAsCache: true,
                          falseChild: SliverToBoxAdapter(
                            child: widget.topPageIndicator,
                          ),
                          trueChild: const SliverSizedBox.shrink(),
                        ),
                      widget.body,
                      if (pageMode == PageMode.infinite)
                        ConditionalValueListenableBuilder(
                          valueListenable: loading,
                          falseChild: const SliverSizedBox.shrink(),
                          trueChild: SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            sliver: SliverToBoxAdapter(
                              child: Center(
                                child: SpinKitPulse(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (pageMode == PageMode.paginated)
                        ConditionalValueListenableBuilder(
                          valueListenable: refreshing,
                          useFalseChildAsCache: true,
                          trueChild: const SliverSizedBox.shrink(),
                          falseChild: SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 40,
                                bottom: 20,
                              ),
                              child: widget.bottomPageIndicator,
                            ),
                          ),
                        ),
                      _SliverBottomGridPadding(
                        multiSelectController: _multiSelectController,
                        pageMode: pageMode,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginatedSwipe(
    Widget child,
    bool refreshing,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SwipeTo(
      enabled: pageMode == PageMode.paginated && !refreshing,
      swipeRightEnabled: controller.hasPreviousPage(),
      swipeLeftEnabled: controller.hasNextPage(),
      rightSwipeWidget: Chip(
        visualDensity: VisualDensity.compact,
        side: BorderSide(
          color: colorScheme.hintColor,
        ),
        backgroundColor: colorScheme.surface,
        label: Row(
          children: [
            Icon(
              Symbols.arrow_back,
              color: colorScheme.onSurface,
              size: 16,
            ),
            const SizedBox(width: 4),
            ValueListenableBuilder(
              valueListenable: controller.pageNotifier,
              builder: (_, page, __) => Text('Page ${page - 1}'),
            ),
          ],
        ),
      ),
      leftSwipeWidget: Chip(
        visualDensity: VisualDensity.compact,
        side: BorderSide(
          color: colorScheme.hintColor,
        ),
        backgroundColor: colorScheme.surface,
        label: Row(
          children: [
            ValueListenableBuilder(
              valueListenable: controller.pageNotifier,
              builder: (_, page, __) => Text('Page ${page + 1}'),
            ),
            const SizedBox(width: 4),
            Icon(
              Symbols.arrow_forward,
              color: colorScheme.onSurface,
              size: 16,
            ),
          ],
        ),
      ),
      onLeftSwipe: (_) => widget.onNextPage(),
      onRightSwipe: (_) => widget.onPreviousPage(),
      child: child,
    );
  }
}

class _CustomScrollView extends StatelessWidget {
  const _CustomScrollView({
    required this.slivers,
    required this.controller,
  });

  final List<Widget> slivers;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      // Material scroll make it easier to pull to refresh
      behavior: const MaterialScrollBehavior(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        controller: controller,
        slivers: slivers,
      ),
    );
  }
}

class _SliverBottomGridPadding extends StatelessWidget {
  const _SliverBottomGridPadding({
    required this.multiSelectController,
    required this.pageMode,
  });

  final MultiSelectController<Post> multiSelectController;
  final PageMode pageMode;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return ValueListenableBuilder(
      valueListenable: multiSelectController.multiSelectNotifier,
      builder: (_, multiSelect, __) {
        return SliverSizedBox(
          height: switch (pageMode) {
            PageMode.infinite =>
              multiSelect ? bottomPadding + 72 : bottomPadding,
            PageMode.paginated => multiSelect ? 36 : 0,
          },
        );
      },
    );
  }
}

// 1GB threshold
const _kImageCacheThreshold = 1000 * 1024 * 1024;
