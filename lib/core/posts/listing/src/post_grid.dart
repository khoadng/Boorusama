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
import '../../../../boorus/booru_builder.dart';
import '../../../../boorus/booru_builder_default.dart';
import '../../../../dart.dart';
import '../../../../foundation/animations.dart';
import '../../../../foundation/display.dart';
import '../../../../foundation/gestures.dart';
import '../../../../foundation/keyboard.dart';
import '../../../../foundation/networking/network_provider.dart';
import '../../../../foundation/networking/network_state.dart';
import '../../../../foundation/toast.dart';
import '../../../../router.dart';
import '../../../../widgets/widgets.dart';
import '../../../boorus.dart';
import '../../../cache/providers.dart';
import '../../../configs/ref.dart';
import '../../../images/booru_image.dart';
import '../../../images/explicit_block_overlay.dart';
import '../../../settings.dart';
import '../../../settings/data.dart';
import '../../../settings/data/listing_provider.dart';
import '../../../theme.dart';
import '../../../widgets/widgets.dart';
import '../../post/post.dart';
import 'conditional_value_listenable_builder.dart';
import 'general_post_context_menu.dart';
import 'post_grid_config_icon_button.dart';
import 'post_grid_controller.dart';
import 'post_list_configuration_header.dart';
import 'sliver_post_grid.dart';
import 'swipe_to.dart';

typedef IndexedSelectableWidgetBuilder<T extends Post> = Widget Function(
  BuildContext context,
  int index,
  MultiSelectController<T> multiSelectController,
  AutoScrollController autoScrollController,
);

class PostGrid<T extends Post> extends ConsumerStatefulWidget {
  const PostGrid({
    super.key,
    this.sliverHeaders,
    this.scrollController,
    this.blacklistedIdString,
    this.multiSelectController,
    required this.controller,
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
  ConsumerState<PostGrid<T>> createState() => _PostGridState();
}

class _PostGridState<T extends Post> extends ConsumerState<PostGrid<T>> {
  final expanded = ValueNotifier<bool?>(null);
  late final AutoScrollController _autoScrollController;
  late final _multiSelectController =
      widget.multiSelectController ?? MultiSelectController<T>();

  @override
  void initState() {
    super.initState();
    _autoScrollController = widget.scrollController ?? AutoScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.multiSelectController == null) {
      _multiSelectController.dispose();
    }

    if (widget.scrollController == null) {
      _autoScrollController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(imageListingSettingsProvider);
    final booruBuilder = ref.watch(currentBooruBuilderProvider);

    final multiSelectActions = booruBuilder?.multiSelectionActionsBuilder?.call(
      context,
      _multiSelectController,
    );

    return LayoutBuilder(
      builder: (context, constraints) => RawPostGrid(
        sliverHeaders: [
          ...widget.sliverHeaders ?? [],
          const SliverMasonryGridWarning(),
        ],
        scrollController: _autoScrollController,
        footer: multiSelectActions,
        blacklistedIdString: widget.blacklistedIdString,
        multiSelectController: _multiSelectController,
        controller: widget.controller,
        safeArea: widget.safeArea,
        gridHeader: _buildConfigHeader(ref, Axis.horizontal),
        settings: settings,
        body: widget.body ??
            SliverPostGrid(
              postController: widget.controller,
              constraints: constraints,
              itemBuilder: (context, index) =>
                  widget.itemBuilder?.call(
                    context,
                    index,
                    _multiSelectController,
                    _autoScrollController,
                  ) ??
                  DefaultImageGridItem(
                    index: index,
                    multiSelectController: _multiSelectController,
                    autoScrollController: _autoScrollController,
                    controller: widget.controller,
                  ),
            ),
      ),
    );
  }

  Widget _buildConfigHeader(WidgetRef ref, Axis axis) {
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
                  valueListenable: expanded,
                  builder: (_, expand, __) => PostListConfigurationHeader(
                    axis: axis,
                    postCount: widget.controller.total,
                    initiallyExpanded: axis == Axis.vertical || expand == true,
                    onExpansionChanged: (value) => expanded.value = value,
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
                    onClosed: _onClose,
                    onDisableAll: _disableAll,
                    onEnableAll: _enableAll,
                    onChanged: _update,
                    hiddenCount: tagCounts.totalNonDuplicatesPostCount,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _onClose() {
    final hasCustomListing = ref.watch(hasCustomListingSettingsProvider);

    if (hasCustomListing) {
      showErrorToast(context, 'Cannot hide header when using custom listing');
      return;
    }

    final settingsNotifier = ref.watch(settingsNotifierProvider.notifier);

    settingsNotifier.updateWith(
      (s) => s.copyWith(
        listing: s.listing.copyWith(
          showPostListConfigHeader: false,
        ),
      ),
    );
    showSimpleSnackBar(
      duration: AppDurations.extraLongToast,
      context: context,
      content: const Text('You can always show this header again in Settings.'),
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

class SliverMasonryGridWarning extends ConsumerWidget {
  const SliverMasonryGridWarning({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageListType),
    );
    final booruType = ref.watchConfigAuth.booruType;

    return type == ImageListType.masonry && booruType.masonryLayoutUnsupported
        ? SliverToBoxAdapter(
            child: WarningContainer(
              title: 'Layout',
              contentBuilder: (context) => Text(
                'Consider switching to the "Standard" layout. "Masonry" is very jumpy for this booru.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          )
        : const SliverSizedBox.shrink();
  }
}

class RawPostGrid<T extends Post> extends StatefulWidget {
  const RawPostGrid({
    super.key,
    this.onLoadMore,
    this.onRefresh,
    this.sliverHeaders,
    this.scrollController,
    this.extendBody = false,
    this.extendBodyHeight,
    this.footer,
    this.header,
    required this.gridHeader,
    this.blacklistedIdString,
    required this.body,
    this.multiSelectController,
    required this.controller,
    this.refreshAtStart = true,
    this.enablePullToRefresh = true,
    this.safeArea = true,
    required this.settings,
  });

  final VoidCallback? onLoadMore;
  final void Function()? onRefresh;
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

  final ImageListingSettings settings;

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

  var multiSelect = false;

  PostGridController<T> get controller => widget.controller;

  var page = 1;
  var hasMore = true;
  final loading = ValueNotifier(false);
  final refreshing = ValueNotifier(false);
  var items = <T>[];
  late var pageMode = controller.pageMode;
  late var settings = widget.settings;

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
  void didUpdateWidget(covariant RawPostGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.settings != widget.settings) {
      setState(() {
        settings = widget.settings;
      });
    }
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
      page = controller.page;
    });
  }

  void _onScrollToTop() {
    _autoScrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !multiSelect,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onWillPop();
      },
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: ConditionalParentWidget(
          condition: widget.safeArea,
          conditionalBuilder: (child) => SafeArea(
            bottom: false,
            child: child,
          ),
          child: MultiSelectWidget<T>(
            footer: widget.footer,
            multiSelectController: _multiSelectController,
            onMultiSelectChanged: (p0) => setState(() {
              multiSelect = p0;
            }),
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
                        onPressed: () =>
                            _multiSelectController.selectAll(items),
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
                          _buildPaginatedSwipe(context, child, refreshing),
                    ),
                    child: CustomScrollView(
                      controller: _autoScrollController,
                      slivers: [
                        if (widget.sliverHeaders != null)
                          ...widget.sliverHeaders!.map(
                            (e) => SliverOffstage(
                              offstage: multiSelect,
                              sliver: e,
                            ),
                          ),
                        if (settings.showPostListConfigHeader)
                          ConditionalValueListenableBuilder(
                            valueListenable: refreshing,
                            useFalseChildAsCache: true,
                            trueChild: const SliverSizedBox.shrink(),
                            falseChild: SliverPinnedHeader(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: settings.imageGridPadding,
                                ),
                                child: widget.gridHeader,
                              ),
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
                        if (pageMode == PageMode.paginated &&
                            settings.pageIndicatorPosition.isVisibleAtTop)
                          ConditionalValueListenableBuilder(
                            valueListenable: refreshing,
                            useFalseChildAsCache: true,
                            falseChild: SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildPageIndicator(settings),
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (pageMode == PageMode.paginated &&
                            settings.pageIndicatorPosition.isVisibleAtBottom)
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
                                child: _buildPageIndicator(settings),
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
      ),
    );
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

  Widget _buildPageIndicator(ImageListingSettings settings) {
    return ValueListenableBuilder(
      valueListenable: controller.count,
      builder: (_, value, __) => PageSelector(
        totalResults: value,
        itemPerPage: settings.postsPerPage,
        currentPage: page,
        onPrevious:
            controller.hasPreviousPage() ? () => _goToPreviousPage() : null,
        onNext: controller.hasNextPage() ? () => _goToNextPage() : null,
        onPageSelect: (page) => _goToPage(page),
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
          color: Theme.of(context).colorScheme.hintColor,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        label: Row(
          children: [
            Icon(
              Symbols.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
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
          color: Theme.of(context).colorScheme.hintColor,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        label: Row(
          children: [
            Text('Page ${page + 1}'),
            const SizedBox(width: 4),
            Icon(
              Symbols.arrow_forward,
              color: Theme.of(context).colorScheme.onSurface,
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
    final settings = ref.watch(imageListingSettingsProvider);

    return switch (ref.watch(networkStateProvider)) {
      final NetworkConnectedState s =>
        s.result.isMobile && settings.imageQuality.isHighres
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
    super.key,
    required this.threshold,
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
    super.key,
    required this.index,
    required this.multiSelectController,
    required this.autoScrollController,
    required this.controller,
  });

  final int index;
  final MultiSelectController<T> multiSelectController;
  final AutoScrollController autoScrollController;
  final PostGridController<T> controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageListingSettingsProvider);
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final gestures = ref.watchPostGestures?.preview;
    final gridThumbnailUrlBuilder = booruBuilder?.gridThumbnailUrlBuilder;

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
            gestures: gestures,
            child: ExplicitContentBlockOverlay(
              rating: post.rating,
              child: Builder(
                builder: (context) {
                  final item = GestureDetector(
                    onLongPress:
                        gestures.canLongPress && postGesturesHandler != null
                            ? () => postGesturesHandler(
                                  ref,
                                  gestures?.longPress,
                                  post,
                                )
                            : null,
                    child: SliverPostGridImageGridItem(
                      post: post,
                      hideOverlay: multiSelect,
                      onTap: !multiSelect
                          ? () {
                              if (gestures.canTap &&
                                  postGesturesHandler != null) {
                                postGesturesHandler(
                                  ref,
                                  gestures?.tap,
                                  post,
                                );
                              } else {
                                goToPostDetailsPageFromController(
                                  context: context,
                                  controller: controller,
                                  initialIndex: index,
                                  scrollController: autoScrollController,
                                );
                              }
                            }
                          : null,
                      quickActionButton: !multiSelect
                          ? DefaultImagePreviewQuickActionButton(post: post)
                          : null,
                      autoScrollOptions: AutoScrollOptions(
                        controller: autoScrollController,
                        index: index,
                      ),
                      score: post.score,
                      image: BooruImage(
                        aspectRatio: post.aspectRatio,
                        imageUrl: gridThumbnailUrlBuilder != null
                            ? gridThumbnailUrlBuilder(
                                settings.imageQuality,
                                post,
                              )
                            : post.thumbnailImageUrl,
                        borderRadius: BorderRadius.circular(
                          settings.imageBorderRadius,
                        ),
                        forceFill:
                            settings.imageListType == ImageListType.standard,
                        placeholderUrl: post.thumbnailImageUrl,
                      ),
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
