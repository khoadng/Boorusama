// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../boorus/engine/engine.dart';
import '../../../boorus/engine/providers.dart';
import '../../../cache/providers.dart';
import '../../../configs/ref.dart';
import '../../../foundation/animations.dart';
import '../../../foundation/display.dart';
import '../../../foundation/keyboard.dart';
import '../../../foundation/networking/network_provider.dart';
import '../../../foundation/networking/network_state.dart';
import '../../../foundation/toast.dart';
import '../../../images/booru_image.dart';
import '../../../router.dart';
import '../../../settings/providers.dart';
import '../../../settings/settings.dart';
import '../../../theme.dart';
import '../../../utils/file_utils.dart';
import '../../details/routes.dart';
import '../../post/post.dart';
import '../../post/widgets.dart';
import 'conditional_value_listenable_builder.dart';
import 'general_post_context_menu.dart';
import 'post_grid_config_icon_button.dart';
import 'post_grid_controller.dart';
import 'post_list_configuration_header.dart';
import 'sliver_post_grid.dart';
import 'sliver_post_grid_image_grid_item.dart';
import 'swipe_to.dart';

typedef IndexedSelectableWidgetBuilder<T extends Post> = Widget Function(
  BuildContext context,
  int index,
  MultiSelectController<T> multiSelectController,
  AutoScrollController autoScrollController,
  bool useHero,
);

class PostGrid<T extends Post> extends StatefulWidget {
  const PostGrid({
    required this.controller,
    super.key,
    this.sliverHeaders,
    this.scrollController,
    this.blacklistedIdString,
    this.multiSelectController,
    this.safeArea = true,
    this.itemBuilder,
    this.body,
  });

  final List<Widget>? sliverHeaders;
  final AutoScrollController? scrollController;
  final bool safeArea;
  final String? blacklistedIdString;
  final MultiSelectController<T>? multiSelectController;
  final PostGridController<T> controller;
  final IndexedSelectableWidgetBuilder<T>? itemBuilder;
  final Widget? body;

  @override
  State<PostGrid<T>> createState() => _PostGridState();
}

class _PostGridState<T extends Post> extends State<PostGrid<T>> {
  final _expanded = ValueNotifier<bool?>(null);
  late final AutoScrollController _autoScrollController =
      widget.scrollController ?? AutoScrollController();
  late final _multiSelectController =
      widget.multiSelectController ?? MultiSelectController<T>();

  final ValueNotifier<bool> _disableHero = ValueNotifier(false);

  @override
  void dispose() {
    super.dispose();
    if (widget.multiSelectController == null) {
      _multiSelectController.dispose();
    }

    if (widget.scrollController == null) {
      _autoScrollController.dispose();
    }

    _disableHero.dispose();
    _expanded.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => RawPostGrid(
        sliverHeaders: [
          ...widget.sliverHeaders ?? [],
          DisableGridItemHeroOnPop(disableHero: _disableHero),
        ],
        scrollController: _autoScrollController,
        footer: Consumer(
          builder: (_, ref, __) {
            final booruBuilder = ref.watch(currentBooruBuilderProvider);

            final multiSelectActions =
                booruBuilder?.multiSelectionActionsBuilder?.call(
              context,
              _multiSelectController,
            );

            return multiSelectActions ?? const SizedBox.shrink();
          },
        ),
        blacklistedIdString: widget.blacklistedIdString,
        multiSelectController: _multiSelectController,
        controller: widget.controller,
        safeArea: widget.safeArea,
        gridHeader: Consumer(
          builder: (_, ref, __) {
            final showHeader = ref.watch(
              imageListingSettingsProvider
                  .select((v) => v.showPostListConfigHeader),
            );

            return showHeader
                ? _buildConfigHeader(ref, Axis.horizontal)
                : const SizedBox.shrink();
          },
        ),
        topPageIndicator: Consumer(
          builder: (_, ref, __) {
            final visibleAtTop = ref.watch(
              imageListingSettingsProvider
                  .select((v) => v.pageIndicatorPosition.isVisibleAtTop),
            );

            return visibleAtTop
                ? _buildPageIndicator(ref)
                : const SizedBox.shrink();
          },
        ),
        bottomPageIndicator: Consumer(
          builder: (_, ref, __) {
            final visibleAtBottom = ref.watch(
              imageListingSettingsProvider
                  .select((v) => v.pageIndicatorPosition.isVisibleAtBottom),
            );

            return visibleAtBottom
                ? _buildPageIndicator(ref)
                : const SizedBox.shrink();
          },
        ),
        onNextPage: _goToNextPage,
        onPreviousPage: _goToPreviousPage,
        body: widget.body ??
            SliverPostGrid(
              postController: widget.controller,
              constraints: constraints,
              itemBuilder: (context, index) => ValueListenableBuilder(
                valueListenable: _disableHero,
                builder: (_, disableHero, __) =>
                    widget.itemBuilder?.call(
                      context,
                      index,
                      _multiSelectController,
                      _autoScrollController,
                      !disableHero,
                    ) ??
                    DefaultImageGridItem(
                      index: index,
                      multiSelectController: _multiSelectController,
                      autoScrollController: _autoScrollController,
                      controller: widget.controller,
                      useHero: !disableHero,
                    ),
              ),
            ),
      ),
    );
  }

  Widget _buildConfigHeader(WidgetRef ref, Axis axis) {
    final imageGridPadding = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageGridPadding),
    );

    return ValueListenableBuilder(
      valueListenable: widget.controller.hasBlacklist,
      builder: (context, hasBlacklist, _) {
        return ValueListenableBuilder(
          valueListenable: widget.controller.tagCounts,
          builder: (context, tagCounts, child) {
            return ValueListenableBuilder(
              valueListenable: widget.controller.activeFilters,
              builder: (context, activeFilters, child) {
                return ValueListenableBuilder(
                  valueListenable: _expanded,
                  builder: (_, expand, __) => Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: imageGridPadding,
                    ),
                    child: PostListConfigurationHeader(
                      axis: axis,
                      postCount: widget.controller.total,
                      initiallyExpanded:
                          axis == Axis.vertical || expand == true,
                      onExpansionChanged: (value) => _expanded.value = value,
                      hasBlacklist: hasBlacklist,
                      tags: activeFilters.keys
                          .map(
                            (e) => (
                              name: e,
                              count: tagCounts[e]?.length ?? 0,
                              active: activeFilters[e] ?? false,
                            ),
                          )
                          .where((e) => e.count > 0)
                          .toList(),
                      trailing: axis == Axis.horizontal
                          ? PostGridConfigIconButton(
                              postController: widget.controller,
                            )
                          : null,
                      onClosed: () {
                        final hasCustomListing =
                            ref.read(hasCustomListingSettingsProvider);

                        if (hasCustomListing) {
                          showErrorToast(
                            context,
                            'Cannot hide header when using custom listing',
                          );
                          return;
                        }

                        final settingsNotifier =
                            ref.read(settingsNotifierProvider.notifier)
                              ..updateWith(
                                (s) => s.copyWith(
                                  listing: s.listing.copyWith(
                                    showPostListConfigHeader: false,
                                  ),
                                ),
                              );
                        showSimpleSnackBar(
                          duration: AppDurations.extraLongToast,
                          context: context,
                          content: const Text(
                            'You can always show this header again in Settings.',
                          ),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () => settingsNotifier.updateWith(
                              (s) => s.copyWith(
                                listing: s.listing.copyWith(
                                  showPostListConfigHeader: true,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      onDisableAll: _disableAll,
                      onEnableAll: _enableAll,
                      onChanged: _update,
                      hiddenCount: tagCounts.totalNonDuplicatesPostCount,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPageIndicator(WidgetRef ref) {
    final controller = widget.controller;
    final postsPerPage = ref.watch(
      imageListingSettingsProvider.select((v) => v.postsPerPage),
    );

    return ValueListenableBuilder(
      valueListenable: controller.count,
      builder: (_, value, __) => ValueListenableBuilder(
        valueListenable: controller.pageNotifier,
        builder: (_, page, __) => PageSelector(
          totalResults: value,
          itemPerPage: postsPerPage,
          currentPage: page,
          onPrevious:
              controller.hasPreviousPage() ? () => _goToPreviousPage() : null,
          onNext: controller.hasNextPage() ? () => _goToNextPage() : null,
          onPageSelect: (page) => _goToPage(page),
        ),
      ),
    );
  }

  Future<void> _goToNextPage() async {
    final controller = widget.controller;

    await controller.goToNextPage();
    _autoScrollController.jumpTo(0);
  }

  Future<void> _goToPreviousPage() async {
    final controller = widget.controller;

    await controller.goToPreviousPage();
    _autoScrollController.jumpTo(0);
  }

  Future<void> _goToPage(int page) async {
    final controller = widget.controller;

    await controller.jumpToPage(page);
    _autoScrollController.jumpTo(0);
  }

  void _update(tag, hide) {
    if (hide) {
      widget.controller.enableTag(tag);
    } else {
      widget.controller.disableTag(tag);
    }
  }

  void _enableAll() {
    widget.controller.enableAllTags();
  }

  void _disableAll() {
    widget.controller.disableAllTags();
  }
}

class DisableGridItemHeroOnPop extends ConsumerWidget {
  const DisableGridItemHeroOnPop({
    required this.disableHero,
    super.key,
  });

  final ValueNotifier<bool> disableHero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          disableHero.value = true;
        }
      },
      child: const SliverSizedBox.shrink(),
    );
  }
}

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
    this.extendBody = false,
    this.extendBodyHeight,
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

  final bool extendBody;
  final double? extendBodyHeight;

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
            extendBody: true,
            floatingActionButton: ScrollToTop(
              scrollController: _autoScrollController,
              onBottomReached: () {
                if (controller.pageMode == PageMode.infinite && hasMore) {
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
                  child: CustomScrollView(
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
                      const SliverSizedBox(
                        height: 4,
                      ),
                      if (pageMode == PageMode.paginated)
                        ConditionalValueListenableBuilder(
                          valueListenable: refreshing,
                          useFalseChildAsCache: true,
                          falseChild: SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: widget.topPageIndicator,
                            ),
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
                      SliverSizedBox(
                        height: MediaQuery.viewPaddingOf(context).bottom + 12,
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

class HighresPreviewOnMobileDataWarningBanner extends ConsumerWidget {
  const HighresPreviewOnMobileDataWarningBanner({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageQuality = ref.watch(imageListingQualityProvider);

    return switch (ref.watch(networkStateProvider)) {
      final NetworkConnectedState s =>
        s.result.isMobile && imageQuality.isHighres
            ? DismissableInfoContainer(
                mainColor: Theme.of(context).colorScheme.error,
                content:
                    'Caution: The app is displaying high-resolution images using mobile data.',
              )
            : const SizedBox.shrink(),
      _ => const SizedBox.shrink(),
    };
  }
}

final _imageCachesProvider = FutureProvider<int>((ref) async {
  final miscData = ref.watch(miscDataBoxProvider);
  final hideWarning = miscData.get(_kHideImageCacheWarningKey) == 'true';

  if (hideWarning) return -1;

  final imageCacheSize = await getImageCacheSize();

  return imageCacheSize.size;
});

// Only need check once at the start
final _cacheImageActionsPerformedProvider = StateProvider<bool>((ref) => false);

const _kHideImageCacheWarningKey = 'hide_image_cache_warning';

// 1GB threshold
const _kImageCacheThreshold = 1000 * 1024 * 1024;

class TooMuchCachedImagesWarningBanner extends ConsumerWidget {
  const TooMuchCachedImagesWarningBanner({
    required this.threshold,
    super.key,
  });

  final int threshold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performed = ref.watch(_cacheImageActionsPerformedProvider);

    if (performed) return const SizedBox.shrink();

    return ref.watch(_imageCachesProvider).when(
          data: (cacheSize) {
            if (cacheSize > threshold) {
              final miscData = ref.watch(miscDataBoxProvider);

              return DismissableInfoContainer(
                mainColor: Theme.of(context).colorScheme.primary,
                content:
                    'The app has stored <b>${Filesize.parse(cacheSize)}</b> worth of images. Would you like to clear it to free up some space?',
                actions: [
                  FilledButton(
                    onPressed: () async {
                      ref
                          .read(_cacheImageActionsPerformedProvider.notifier)
                          .state = true;
                      final success = await clearImageCache();

                      final c = navigatorKey.currentState?.context;

                      if (c != null && c.mounted) {
                        if (success) {
                          showSuccessToast(context, 'Cache cleared');
                        } else {
                          showErrorToast(context, 'Failed to clear cache');
                        }
                      }
                    },
                    child: const Text('settings.performance.clear_cache').tr(),
                  ),
                  TextButton(
                    onPressed: () {
                      miscData.put(_kHideImageCacheWarningKey, 'true');
                      ref
                          .read(_cacheImageActionsPerformedProvider.notifier)
                          .state = true;
                    },
                    child: const Text("Don't show again"),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
        );
  }
}

class DefaultImageGridItem<T extends Post> extends ConsumerWidget {
  const DefaultImageGridItem({
    required this.index,
    required this.multiSelectController,
    required this.autoScrollController,
    required this.controller,
    required this.useHero,
    super.key,
  });

  final int index;
  final MultiSelectController<T> multiSelectController;
  final AutoScrollController autoScrollController;
  final PostGridController<T> controller;
  final bool useHero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: multiSelectController.multiSelectNotifier,
      builder: (_, multiSelect, __) => ValueListenableBuilder(
        valueListenable: controller.itemsNotifier,
        builder: (_, posts, __) {
          final post = posts[index];

          return DefaultPostListContextMenuRegion(
            isEnabled: !multiSelect,
            contextMenu: GeneralPostContextMenu(
              hasAccount: ref.watchConfigAuth.hasLoginDetails(),
              onMultiSelect: () {
                multiSelectController.enableMultiSelect();
              },
              post: post,
            ),
            child: ExplicitContentBlockOverlay(
              rating: post.rating,
              child: Builder(
                builder: (context) {
                  final item = SliverPostGridImageGridItem(
                    post: post,
                    multiSelectEnabled: multiSelect,
                    onTap: () {
                      goToPostDetailsPageFromController(
                        context: context,
                        controller: controller,
                        initialIndex: index,
                        scrollController: autoScrollController,
                      );
                    },
                    quickActionButton: !multiSelect
                        ? DefaultImagePreviewQuickActionButton(post: post)
                        : null,
                    autoScrollOptions: AutoScrollOptions(
                      controller: autoScrollController,
                      index: index,
                    ),
                    score: post.score,
                    image: BooruHero(
                      tag: useHero ? '${post.id}_hero' : null,
                      child: _Image(post: post),
                    ),
                  );

                  return multiSelect
                      ? ValueListenableBuilder(
                          valueListenable:
                              multiSelectController.selectedItemsNotifier,
                          builder: (_, selectedItems, __) => SelectableItem(
                            index: index,
                            isSelected: selectedItems.contains(post),
                            onTap: () =>
                                multiSelectController.toggleSelection(post),
                            itemBuilder: (context, isSelected) => item,
                          ),
                        )
                      : item;
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Image<T extends Post> extends ConsumerWidget {
  const _Image({
    required this.post,
    super.key,
  });

  final T post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final gridThumbnailUrlBuilder = booruBuilder?.gridThumbnailUrlBuilder;
    final imageQuality = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageQuality),
    );
    final imageBorderRadius = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageBorderRadius),
    );
    final imageListType = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageListType),
    );

    return BooruImage(
      aspectRatio: post.aspectRatio,
      imageUrl: gridThumbnailUrlBuilder != null
          ? gridThumbnailUrlBuilder(
              imageQuality,
              post,
            )
          : post.thumbnailImageUrl,
      borderRadius: BorderRadius.circular(
        imageBorderRadius,
      ),
      forceFill: imageListType == ImageListType.standard,
      placeholderUrl: post.thumbnailImageUrl,
    );
  }
}
