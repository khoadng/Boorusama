// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/utils.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/networking/network_provider.dart';
import 'package:boorusama/foundation/networking/network_state.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

typedef ItemWidgetBuilder<T> = Widget Function(
    BuildContext context, List<T> items, int index);

class PostGrid<T extends Post> extends ConsumerStatefulWidget {
  const PostGrid({
    super.key,
    this.onLoadMore,
    this.onRefresh,
    this.sliverHeaders,
    this.scrollController,
    this.contextMenuBuilder,
    this.multiSelectActions,
    this.extendBody = false,
    this.extendBodyHeight,
    required this.itemBuilder,
    this.footerBuilder,
    this.headerBuilder,
    this.blacklistedIdString,
    required this.bodyBuilder,
    this.multiSelectController,
    required this.controller,
    this.refreshAtStart = true,
    this.enablePullToRefresh = true,
    this.safeArea = true,
  });

  final VoidCallback? onLoadMore;
  final void Function()? onRefresh;
  final List<Widget>? sliverHeaders;
  final AutoScrollController? scrollController;
  final Widget Function(Post post, void Function() next)? contextMenuBuilder;

  final bool extendBody;
  final double? extendBodyHeight;

  final bool refreshAtStart;
  final bool enablePullToRefresh;
  final bool safeArea;

  final ItemWidgetBuilder<T> itemBuilder;
  final FooterBuilder<T>? footerBuilder;
  final HeaderBuilder<T>? headerBuilder;
  final Widget Function(
    BuildContext context,
    IndexedWidgetBuilder itemBuilder,
    bool refreshing,
    List<T> data,
  ) bodyBuilder;

  final String? blacklistedIdString;

  final MultiSelectController<T>? multiSelectController;

  final PostGridController<T> controller;

  final Widget Function(
    Iterable<Post> selectedPosts,
    void Function() endMultiSelect,
  )? multiSelectActions;

  @override
  ConsumerState<PostGrid<T>> createState() => _InfinitePostListState();
}

class _InfinitePostListState<T extends Post> extends ConsumerState<PostGrid<T>>
    with TickerProviderStateMixin {
  late final AutoScrollController _autoScrollController;
  late final MultiSelectController<T> _multiSelectController;

  var multiSelect = false;

  PostGridController<T> get controller => widget.controller;

  var page = 1;
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
  }

  @override
  void dispose() {
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
      page = controller.page;
    });
  }

  void _onScrollToTop() {
    _autoScrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return PopScope(
        canPop: !multiSelect,
        onPopInvoked: (didPop) {
          if (didPop) return;
          _onWillPop();
        },
        child: ColoredBox(
          color: context.theme.scaffoldBackgroundColor,
          child: PostGridConfigRegion(
            postController: controller,
            blacklistHeader: _buildConfigHeader(
                !kPreferredLayout.isMobile ? Axis.vertical : Axis.horizontal),
            builder: (context, header) => ConditionalParentWidget(
              condition: widget.safeArea,
              conditionalBuilder: (child) => SafeArea(
                bottom: false,
                child: child,
              ),
              child: MultiSelectWidget<T>(
                footerBuilder: widget.footerBuilder,
                multiSelectController: _multiSelectController,
                onMultiSelectChanged: (p0) => setState(() {
                  multiSelect = p0;
                }),
                headerBuilder: (context, selected, clearSelected, selectAll) =>
                    widget.headerBuilder != null
                        ? widget.headerBuilder!(
                            context, selected, clearSelected, selectAll)
                        : AppBar(
                            leading: IconButton(
                              onPressed: () =>
                                  _multiSelectController.disableMultiSelect(),
                              icon: const Icon(Symbols.close),
                            ),
                            actions: [
                              IconButton(
                                onPressed: selectAll,
                                icon: const Icon(Symbols.select_all),
                              ),
                              IconButton(
                                onPressed: clearSelected,
                                icon: const Icon(Symbols.clear_all),
                              ),
                            ],
                            title: selected.isEmpty
                                ? const Text('Select items')
                                : Text('${selected.length} Items selected'),
                          ),
                items: items,
                itemBuilder: (context, index) =>
                    widget.itemBuilder(context, items, index),
                scrollableWidgetBuilder: (context, items, itemBuilder) {
                  return Scaffold(
                    extendBody: true,
                    floatingActionButton: ScrollToTop(
                      scrollController: _autoScrollController,
                      onBottomReached: () {
                        if (controller.pageMode == PageMode.infinite &&
                            hasMore) {
                          widget.onLoadMore?.call();
                          controller.fetchMore();
                        }
                      },
                      child: widget.extendBody
                          ? Padding(
                              padding: EdgeInsets.only(
                                bottom: widget.extendBodyHeight ??
                                    kBottomNavigationBarHeight,
                              ),
                              child: BooruScrollToTopButton(
                                onPressed: _onScrollToTop,
                              ),
                            )
                          : BooruScrollToTopButton(
                              onPressed: _onScrollToTop,
                            ),
                    ),
                    body: ConditionalParentWidget(
                      condition: kPreferredLayout.isMobile,
                      conditionalBuilder: (child) => RefreshIndicator(
                        edgeOffset: 60,
                        displacement: 50,
                        notificationPredicate: widget.enablePullToRefresh
                            ? (_) => true
                            : (_) => false,
                        onRefresh: () async {
                          widget.onRefresh?.call();
                          _multiSelectController.clearSelected();
                          await controller.refresh();
                        },
                        child: child,
                      ),
                      child: ImprovedScrolling(
                        scrollController: _autoScrollController,
                        // https://github.com/adrianflutur/flutter_improved_scrolling/issues/5
                        enableKeyboardScrolling: false,
                        enableMMBScrolling: true,
                        child: ConditionalParentWidget(
                          // Should remove this later
                          condition: true,
                          conditionalBuilder: (child) => ValueListenableBuilder(
                            valueListenable: refreshing,
                            builder: (_, refreshing, __) =>
                                _buildPaginatedSwipe(
                                    context, child, refreshing),
                          ),
                          child: CustomScrollView(
                            controller: _autoScrollController,
                            slivers: [
                              if (widget.sliverHeaders != null)
                                ...widget.sliverHeaders!
                                    .map((e) => SliverOffstage(
                                          offstage: multiSelect,
                                          sliver: e,
                                        )),
                              if (settings.showPostListConfigHeader)
                                if (kPreferredLayout.isMobile)
                                  ConditionalValueListenableBuilder(
                                    valueListenable: refreshing,
                                    useFalseChildAsCache: true,
                                    trueChild: const SliverSizedBox.shrink(),
                                    falseChild: SliverPinnedHeader(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: settings.imageGridPadding,
                                        ),
                                        child: header,
                                      ),
                                    ),
                                  ),
                              ConditionalValueListenableBuilder(
                                valueListenable: refreshing,
                                useFalseChildAsCache: true,
                                trueChild: const SliverSizedBox.shrink(),
                                falseChild: const SliverToBoxAdapter(
                                  child:
                                      HighresPreviewOnMobileDataWarningBanner(),
                                ),
                              ),
                              const SliverSizedBox(
                                height: 4,
                              ),
                              if (pageMode == PageMode.paginated &&
                                  settings.pageIndicatorPosition.isVisibleAtTop)
                                ConditionalValueListenableBuilder(
                                  valueListenable: refreshing,
                                  useFalseChildAsCache: true,
                                  falseChild: SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: PageSelector(
                                        currentPage: page,
                                        onPrevious: controller.hasPreviousPage()
                                            ? () => _goToPreviousPage()
                                            : null,
                                        onNext: controller.hasNextPage()
                                            ? () => _goToNextPage()
                                            : null,
                                        onPageSelect: (page) => _goToPage(page),
                                      ),
                                    ),
                                  ),
                                  trueChild: const SliverSizedBox.shrink(),
                                ),
                              ValueListenableBuilder(
                                valueListenable: refreshing,
                                builder: (context, refreshing, child) =>
                                    widget.bodyBuilder(
                                  context,
                                  itemBuilder,
                                  refreshing,
                                  items,
                                ),
                              ),
                              if (pageMode == PageMode.infinite)
                                ConditionalValueListenableBuilder(
                                  valueListenable: loading,
                                  falseChild: const SliverSizedBox.shrink(),
                                  trueChild: SliverPadding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    sliver: SliverToBoxAdapter(
                                      child: Center(
                                        child: SpinKitPulse(
                                          color: context
                                              .theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (pageMode == PageMode.paginated &&
                                  settings
                                      .pageIndicatorPosition.isVisibleAtBottom)
                                ConditionalValueListenableBuilder(
                                  valueListenable: refreshing,
                                  useFalseChildAsCache: true,
                                  trueChild: const SliverSizedBox.shrink(),
                                  falseChild: _buildPageIndicator(),
                                ),
                              SliverSizedBox(
                                height:
                                    MediaQuery.viewPaddingOf(context).bottom +
                                        12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ));
  }

  Future<void> _goToNextPage() async {
    await controller.goToNextPage();
    _autoScrollController.jumpTo(0);
  }

  Future<void> _goToPreviousPage() async {
    await controller.goToPreviousPage();
    _autoScrollController.jumpTo(0);
  }

  Future<void> _goToPage(int page) async {
    await controller.jumpToPage(page);
    _autoScrollController.jumpTo(0);
  }

  Widget _buildPageIndicator() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 40,
          bottom: 20,
        ),
        child: PageSelector(
          currentPage: page,
          onPrevious:
              controller.hasPreviousPage() ? () => _goToPreviousPage() : null,
          onNext: controller.hasNextPage() ? () => _goToNextPage() : null,
          onPageSelect: (page) => _goToPage(page),
        ),
      ),
    );
  }

  Widget _buildPaginatedSwipe(
    BuildContext context,
    Widget child,
    bool refreshing,
  ) {
    return SwipeTo(
      enabled: pageMode == PageMode.paginated && !refreshing,
      swipeRightEnabled: controller.hasPreviousPage(),
      swipeLeftEnabled: controller.hasNextPage(),
      rightSwipeWidget: Chip(
        visualDensity: VisualDensity.compact,
        side: BorderSide(
          width: 1,
          color: context.theme.hintColor,
        ),
        backgroundColor: context.colorScheme.surface,
        label: Row(
          children: [
            Icon(
              Symbols.arrow_back,
              color: context.theme.colorScheme.onSurface,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text('Page ${page - 1}'),
          ],
        ),
      ),
      leftSwipeWidget: Chip(
        visualDensity: VisualDensity.compact,
        side: BorderSide(
          width: 1,
          color: context.theme.hintColor,
        ),
        backgroundColor: context.colorScheme.surface,
        label: Row(
          children: [
            Text('Page ${page + 1}'),
            const SizedBox(width: 4),
            Icon(
              Symbols.arrow_forward,
              color: context.theme.colorScheme.onSurface,
              size: 16,
            ),
          ],
        ),
      ),
      onLeftSwipe: (_) => _goToNextPage(),
      onRightSwipe: (_) => _goToPreviousPage(),
      child: child,
    );
  }

  Widget _buildConfigHeader(Axis axis) {
    return ValueListenableBuilder(
      valueListenable: controller.hasBlacklist,
      builder: (context, hasBlacklist, _) {
        return ValueListenableBuilder(
          valueListenable: controller.tagCounts,
          builder: (context, tagCounts, child) {
            return ValueListenableBuilder(
              valueListenable: controller.activeFilters,
              builder: (context, activeFilters, child) {
                final hiddenTags = activeFilters.keys
                    .map((e) => (
                          name: e,
                          count: tagCounts[e]?.length ?? 0,
                          active: activeFilters[e] ?? false,
                        ))
                    .where((e) => e.count > 0)
                    .toList();

                return PostListConfigurationHeader(
                  axis: axis,
                  postCount: controller.total,
                  initiallyExpanded: axis == Axis.vertical,
                  hasBlacklist: hasBlacklist,
                  tags: hiddenTags,
                  trailing: axis == Axis.horizontal
                      ? PostGridConfigIconButton(
                          postController: controller,
                        )
                      : null,
                  onClosed: () {
                    ref.setPostListConfigHeaderStatus(
                      active: false,
                    );
                    showSimpleSnackBar(
                      duration: const Duration(seconds: 5),
                      context: context,
                      content: const Text(
                          'You can always show this header again in Settings.'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () =>
                            ref.setPostListConfigHeaderStatus(active: true),
                      ),
                    );
                  },
                  onDisableAll: _disableAll,
                  onEnableAll: _enableAll,
                  onChanged: _update,
                  hiddenCount: tagCounts.totalNonDuplicatesPostCount,
                );
              },
            );
          },
        );
      },
    );
  }

  void _update(tag, hide) {
    if (hide) {
      controller.enableTag(tag);
    } else {
      controller.disableTag(tag);
    }
  }

  void _enableAll() {
    controller.enableAllTags();
  }

  void _disableAll() {
    controller.disableAllTags();
  }

  void _onWillPop() {
    if (multiSelect) {
      _multiSelectController.disableMultiSelect();
    }
  }
}

class HighresPreviewOnMobileDataWarningBanner extends ConsumerWidget {
  const HighresPreviewOnMobileDataWarningBanner({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return switch (ref.watch(networkStateProvider)) {
      NetworkConnectedState s =>
        s.result.isMobile && settings.imageQuality.isHighres
            ? DismissableInfoContainer(
                mainColor: context.colorScheme.error,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                content:
                    'Caution: The app is displaying high-resolution images using mobile data.',
              )
            : const SizedBox.shrink(),
      _ => const SizedBox.shrink(),
    };
  }
}
