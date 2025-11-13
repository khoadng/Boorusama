// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:oktoast/oktoast.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:selection_mode/selection_mode.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../../foundation/keyboard.dart';
import '../../../../haptics/types.dart';
import '../../../../themes/theme/types.dart';
import '../../../../widgets/animated_footer.dart';
import '../../../../widgets/default_selection_bar.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/types.dart';
import '../types/grid_size.dart';
import '../types/grid_utils.dart';
import '../types/page_mode.dart';
import '../widgets/conditional_value_listenable_builder.dart';
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
    required this.scrollToTopButton,
    required this.body,
    required this.controller,
    required this.onNextPage,
    required this.onPreviousPage,
    required this.selectionModeController,
    required this.selectionOptions,
    super.key,
    this.sliverHeaders,
    this.scrollController,
    this.footer,
    this.blacklistedIdString,
    this.refreshAtStart = true,
    this.enablePullToRefresh = true,
    this.safeArea = true,
    this.options = const PostGridOptions(),
  });

  final void Function() onNextPage;
  final void Function() onPreviousPage;
  final List<Widget>? sliverHeaders;
  final AutoScrollController? scrollController;

  final bool refreshAtStart;
  final bool enablePullToRefresh;
  final bool safeArea;

  final Widget? footer;
  final Widget body;
  final Widget gridHeader;
  final Widget topPageIndicator;
  final Widget bottomPageIndicator;
  final Widget scrollToTopButton;

  final String? blacklistedIdString;

  final SelectionModeController selectionModeController;
  final SelectionOptions selectionOptions;

  final PostGridController<T> controller;
  final PostGridOptions options;

  @override
  State<RawPostGrid<T>> createState() => _RawPostGridState();
}

class _RawPostGridState<T extends Post> extends State<RawPostGrid<T>>
    with TickerProviderStateMixin, KeyboardListenerMixin {
  late final AutoScrollController _autoScrollController;
  late final SelectionModeController _selectionModeController;
  late SelectionOptions _selectionOptions;
  late PostGridOptions _options;

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
    _selectionModeController = widget.selectionModeController;

    controller.addListener(_onControllerChange);
    if (widget.refreshAtStart) {
      controller.refresh();
    }

    _selectionOptions = widget.selectionOptions;
    _options = widget.options;

    registerListener(_handleKeyEvent);
  }

  @override
  void didUpdateWidget(RawPostGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectionOptions != oldWidget.selectionOptions) {
      setState(() {
        _selectionOptions = widget.selectionOptions;
      });
    }

    if (widget.options != oldWidget.options) {
      setState(() {
        _options = widget.options;
      });
    }
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (isKeyPressed(LogicalKeyboardKey.f5, event: event)) {
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

    widget.controller.removeListener(_onControllerChange);

    super.dispose();
  }

  void _onControllerChange() {
    if (!mounted) return;

    // check if refreshing, don't set state if it is
    if (controller.refreshing) {
      refreshing.value = true;

      // reset multi select if something is selected
      if (_selectionModeController.selection.isNotEmpty) {
        _selectionModeController.deselectAll();
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
        child: _SelectionMode(
          footer: widget.footer,
          selectionModeController: _selectionModeController,
          selectionOptions: _selectionOptions,
          autoScrollController: _autoScrollController,
          header: DefaultSelectionBar(
            itemsCount: items.length,
            appBar: const SizedBox.shrink(),
          ),
          child: _Scaffold(
            body: ConditionalParentWidget(
              condition: kPreferredLayout.isMobile,
              conditionalBuilder: (child) => BooruRefreshIndicator(
                edgeOffset: 60,
                displacement: 50,
                notificationPredicate: widget.enablePullToRefresh
                    ? (_) => true
                    : (_) => false,
                onRefresh: () async {
                  _selectionModeController.deselectAll();
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
                child: ValueListenableBuilder(
                  valueListenable: refreshing,
                  builder: (_, refreshing, child) => _SwipeTo(
                    pageMode: pageMode,
                    controller: controller,
                    refreshing: refreshing,
                    onNextPage: widget.onNextPage,
                    onPreviousPage: widget.onPreviousPage,
                    options: _options,
                    child: child!,
                  ),
                  child: PostGridOptionsProvider(
                    options: _options,
                    child: _CustomScrollView(
                      controller: _autoScrollController,
                      slivers: [
                        if (widget.sliverHeaders != null)
                          ...widget.sliverHeaders!.map(
                            (e) => ListenableBuilder(
                              listenable: _selectionModeController,
                              builder: (_, _) {
                                final multiSelect =
                                    _selectionModeController.isActive;

                                return SliverOffstage(
                                  offstage: multiSelect,
                                  sliver: e,
                                );
                              },
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
                          _buildLoadMore(colorScheme),
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
                          selectionModeController: _selectionModeController,
                          pageMode: pageMode,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButton: widget.scrollToTopButton,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMore(ColorScheme colorScheme) {
    void showNoMoreDataMessage() {
      showToast(
        context.t.infinite_scroll.nore_more_data,
        position: ToastPosition.bottom,
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 60,
        ),
        textPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: colorScheme.surfaceContainerHigh,
        textStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: refreshing,
      builder: (context, refresh, child) => ConditionalValueListenableBuilder(
        valueListenable: loading,
        falseChild: switch ((refreshing: refresh, hasMore: hasMore)) {
          (refreshing: false, hasMore: true) => SliverLayoutBuilder(
            builder: (context, constraints) {
              final canScroll =
                  constraints.precedingScrollExtent >
                  constraints.viewportMainAxisExtent;

              return switch (canScroll) {
                true => const SliverSizedBox.shrink(),
                false => SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(120, 40),
                        ),
                        onPressed: () => controller.fetchMore(
                          onNoMoreData: () {
                            showNoMoreDataMessage();
                          },
                        ),
                        child: Text(
                          context.t.infinite_scroll.load_more,
                        ),
                      ),
                    ),
                  ),
                ),
              };
            },
          ),
          _ => const SliverSizedBox.shrink(),
        },
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
    );
  }
}

class _SwipeTo extends StatelessWidget {
  const _SwipeTo({
    required this.pageMode,
    required this.controller,
    required this.refreshing,
    required this.onNextPage,
    required this.onPreviousPage,
    required this.options,
    required this.child,
  });

  final PageMode pageMode;
  final PostGridController controller;
  final bool refreshing;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;
  final PostGridOptions options;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SwipeTo(
      enabled: pageMode == PageMode.paginated && !refreshing,
      swipeRightEnabled: controller.hasPreviousPage(),
      swipeLeftEnabled: controller.hasNextPage(),
      hapticFeedbackEnabled:
          options.hapticFeedbackLevel?.isBalanceAndAbove ?? false,
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
              builder: (_, page, _) => Text(
                context.t.infinite_scroll.page_label(page: page - 1),
              ),
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
              builder: (_, page, _) => Text(
                context.t.infinite_scroll.page_label(page: page + 1),
              ),
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
      onLeftSwipe: (_) => onNextPage(),
      onRightSwipe: (_) => onPreviousPage(),
      child: child,
    );
  }
}

class _Scaffold extends StatelessWidget {
  const _Scaffold({
    required this.body,
    required this.floatingActionButton,
  });

  final Widget body;
  final Widget floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: body,
          ),
          floatingActionButton,
        ],
      ),
    );
  }
}

class PostGridConstraints extends InheritedWidget {
  const PostGridConstraints({
    required this.crossAxisCount,
    required super.child,
    super.key,
  });

  static PostGridConstraints? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PostGridConstraints>();
  }

  final int? crossAxisCount;

  @override
  bool updateShouldNotify(covariant PostGridConstraints oldWidget) {
    return crossAxisCount != oldWidget.crossAxisCount;
  }
}

class PostGridOptionsProvider extends InheritedWidget {
  const PostGridOptionsProvider({
    required this.options,
    required super.child,
    super.key,
  });

  static PostGridOptions of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<PostGridOptionsProvider>();
    assert(result != null, 'No PostGridOptionsProvider found in context');
    return result!.options;
  }

  final PostGridOptions options;

  @override
  bool updateShouldNotify(covariant PostGridOptionsProvider oldWidget) {
    return options != oldWidget.options;
  }
}

class _SelectionMode extends StatelessWidget {
  const _SelectionMode({
    required this.selectionModeController,
    required this.selectionOptions,
    required this.child,
    this.footer,
    this.header,
    this.autoScrollController,
  });

  final Widget? footer;
  final Widget? header;
  final Widget child;
  final SelectionModeController selectionModeController;
  final AutoScrollController? autoScrollController;
  final SelectionOptions? selectionOptions;

  @override
  Widget build(BuildContext context) {
    return SelectionMode(
      controller: selectionModeController,
      options: selectionOptions,
      scrollController: autoScrollController,
      child: Stack(
        children: [
          Column(
            children: [
              if (header case final Widget header) header,
              Expanded(
                child: SelectionCanvas(
                  child: child,
                ),
              ),
            ],
          ),
          if (footer case final Widget footer)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SelectionModeAnimatedFooter(
                child: footer,
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomScrollView extends StatefulWidget {
  const _CustomScrollView({
    required this.slivers,
    required this.controller,
  });

  final List<Widget> slivers;
  final ScrollController? controller;

  @override
  State<_CustomScrollView> createState() => _CustomScrollViewState();
}

class _CustomScrollViewState extends State<_CustomScrollView> {
  @override
  Widget build(BuildContext context) {
    final options = PostGridOptionsProvider.of(context);

    return ScrollConfiguration(
      // Material scroll make it easier to pull to refresh
      behavior: const MaterialScrollBehavior(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = calculateGridCount(
            constraints.maxWidth,
            options.gridSize ?? GridSize.normal,
          );

          return PostGridConstraints(
            crossAxisCount: crossAxisCount,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              controller: widget.controller,
              cacheExtent: options.cacheExtent,
              slivers: widget.slivers,
            ),
          );
        },
      ),
    );
  }
}

class _SliverBottomGridPadding extends StatelessWidget {
  const _SliverBottomGridPadding({
    required this.selectionModeController,
    required this.pageMode,
  });

  final SelectionModeController selectionModeController;
  final PageMode pageMode;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return ListenableBuilder(
      listenable: selectionModeController,
      builder: (_, _) {
        final multiSelect = selectionModeController.isActive;
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

class PostGridOptions extends Equatable {
  const PostGridOptions({
    this.cacheExtent,
    this.hapticFeedbackLevel,
    this.gridSize,
  });

  final double? cacheExtent;
  final HapticFeedbackLevel? hapticFeedbackLevel;
  final GridSize? gridSize;

  @override
  List<Object?> get props => [
    cacheExtent,
    hapticFeedbackLevel,
    gridSize,
  ];
}
