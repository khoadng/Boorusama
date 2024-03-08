// Dart imports:
import 'dart:isolate';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/feats/utils.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/posts/post_grid_config_region.dart';
import 'package:boorusama/foundation/networking/network_provider.dart';
import 'package:boorusama/foundation/networking/network_state.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'post_grid_config_icon_button.dart';
import 'post_grid_controller.dart';
import 'post_list_configuration_header.dart';

final _tagCountProvider =
    AsyncNotifierProvider.autoDispose<_TagCountNotifier, Map<String, int>?>(
        _TagCountNotifier.new);

final _hasBlacklistedTagsProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final tags = await ref.watch(_tagCountProvider.future);
  return tags?.values.any((e) => e > 0) ?? false;
});

class _TagCountNotifier extends AutoDisposeAsyncNotifier<Map<String, int>?> {
  @override
  Future<Map<String, int>?> build() async {
    return null;
  }

  Future<void> count<T extends Post>(
    Iterable<T> posts,
    Iterable<String> tags,
  ) async {
    state = const AsyncValue.data(null);
    state = const AsyncValue.loading();

    final data = await Isolate.run(
      () {
        final Map<String, int> tagCounts = {};
        final preprocessed =
            tags.map((tag) => tag.split(' ').map(TagExpression.parse).toList());

        for (final item in posts) {
          for (final pattern in preprocessed) {
            if (item.containsTagPattern(pattern)) {
              final key = pattern.join(' ');
              tagCounts[key] = (tagCounts[key] ?? 0) + 1;
            }
          }
        }

        return tagCounts;
      },
    );

    state = AsyncValue.data(data);
  }
}

typedef ItemWidgetBuilder<T> = Widget Function(
    BuildContext context, List<T> items, int index);

class PostGrid<T extends Post> extends ConsumerStatefulWidget {
  const PostGrid({
    super.key,
    this.onLoadMore,
    this.onRefresh,
    this.sliverHeaderBuilder,
    this.scrollController,
    this.contextMenuBuilder,
    this.multiSelectActions,
    this.extendBody = false,
    this.extendBodyHeight,
    required this.itemBuilder,
    this.footerBuilder,
    this.headerBuilder,
    this.blacklistedTagString,
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
  final List<Widget> Function(BuildContext context)? sliverHeaderBuilder;
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

  final String? blacklistedTagString;
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
  var loading = false;
  var refreshing = false;
  var items = <T>[];
  var filteredItems = <T>[];
  late var pageMode = controller.pageMode;

  var filters = <String, bool>{};

  @override
  void didUpdateWidget(PostGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blacklistedTagString != widget.blacklistedTagString) {
      _updateFilter();
      _updateData(
        filters: filters,
        bustCache: true,
      );
      _countTags();
    }

    if (oldWidget.blacklistedIdString != widget.blacklistedIdString) {
      _updateData(
        filters: filters,
        bustCache: true,
      );
    }
  }

  void _updateFilter() {
    setState(() {
      final blacklistedTags = widget.blacklistedTagString?.split('\n') ?? [];
      filters = {
        for (final tag in blacklistedTags) tag: true,
      };
    });
  }

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

    _updateFilter();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _autoScrollController.dispose();
    }

    if (widget.multiSelectController == null) {
      _multiSelectController.dispose();
    }

    super.dispose();
  }

  final precomputedFilter = <int, bool>{};

  void _updateData({
    required Map<String, bool> filters,
    bool bustCache = false,
  }) {
    if (bustCache) {
      precomputedFilter.clear();
    }

    final d = filter(
      controller.items,
      {
        for (final tag in filters.keys)
          if (filters[tag]!) tag
      },
      precomputedFilter: precomputedFilter,
    );

    if (!mounted) return;

    // Dirty hack to filter out bookmarked posts
    final settings = ref.read(settingsProvider);

    final bookmarks = settings.shouldFilterBookmarks
        ? ref.read(bookmarkProvider).bookmarks
        : <Bookmark>[].lock;

    final dataWithoutBookmarks = d.data.where((element) =>
        !bookmarks.any((e) => e.originalUrl == element.originalImageUrl));

    // Dirty hack to filter out ids
    final blacklistedIds = widget.blacklistedIdString?.split('\n') ?? [];
    final dataWithoutBookmarksAndIds = dataWithoutBookmarks
        .where((element) => !blacklistedIds.contains(element.id.toString()));

    items = dataWithoutBookmarksAndIds.toList();

    filteredItems = d.filtered;
  }

  Future<void> _countTags() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(_tagCountProvider.notifier).count(
            controller.items,
            filters.keys,
          );
    });
  }

  void _onControllerChange() {
    if (!mounted) return;
    setState(() {
      _updateData(
        filters: filters,
        bustCache: controller.refreshing,
      );
      _countTags();

      hasMore = controller.hasMore;
      loading = controller.loading;
      refreshing = controller.refreshing;
      pageMode = controller.pageMode;
      page = controller.page;
    });
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
                !isMobilePlatform() ? Axis.vertical : Axis.horizontal),
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
                              child: FloatingActionButton(
                                heroTag: null,
                                child: const FaIcon(FontAwesomeIcons.angleUp),
                                onPressed: () =>
                                    _autoScrollController.jumpTo(0),
                              ),
                            )
                          : FloatingActionButton(
                              heroTag: null,
                              child: const FaIcon(FontAwesomeIcons.angleUp),
                              onPressed: () => _autoScrollController.jumpTo(0),
                            ),
                    ),
                    body: ConditionalParentWidget(
                      condition: isMobilePlatform(),
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
                          conditionalBuilder: (child) =>
                              _buildPaginatedSwipe(context, child),
                          child: CustomScrollView(
                            controller: _autoScrollController,
                            slivers: [
                              if (!multiSelect &&
                                  widget.sliverHeaderBuilder != null)
                                ...widget.sliverHeaderBuilder!(context),
                              if (settings.showPostListConfigHeader &&
                                  !refreshing)
                                if (isMobilePlatform())
                                  SliverPinnedHeader(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: settings.imageGridPadding,
                                      ),
                                      child: header,
                                    ),
                                  ),
                              if (!refreshing)
                                const SliverToBoxAdapter(
                                  child:
                                      HighresPreviewOnMobileDataWarningBanner(),
                                ),
                              const SliverSizedBox(
                                height: 4,
                              ),
                              if (!refreshing &&
                                  pageMode == PageMode.paginated &&
                                  settings.pageIndicatorPosition.isVisibleAtTop)
                                SliverToBoxAdapter(
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
                              widget.bodyBuilder(
                                context,
                                itemBuilder,
                                refreshing,
                                items,
                              ),
                              if (pageMode == PageMode.infinite && loading)
                                SliverPadding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  sliver: SliverToBoxAdapter(
                                    child: Center(
                                      child: SpinKitPulse(
                                        color: context
                                            .theme.colorScheme.onBackground,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const SliverSizedBox.shrink(),
                              if (!refreshing &&
                                  pageMode == PageMode.paginated &&
                                  settings
                                      .pageIndicatorPosition.isVisibleAtBottom)
                                _buildPageIndicator(),
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

  Widget _buildPaginatedSwipe(BuildContext context, Widget child) {
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
              color: context.theme.colorScheme.onPrimary,
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
              color: context.theme.colorScheme.onPrimary,
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
    final tagCounts = ref.watch(_tagCountProvider);
    final hasBlacklistedTags = ref.watch(_hasBlacklistedTagsProvider);

    return PostListConfigurationHeader(
      axis: axis,
      postCount: items.length + filteredItems.length,
      initiallyExpanded: axis == Axis.vertical,
      hasBlacklist: hasBlacklistedTags.value ?? false,
      tags: tagCounts.value != null
          ? filters.keys
              .map((e) => (
                    name: e,
                    count: tagCounts.value![e] ?? 0,
                    active: filters[e] ?? false,
                  ))
              .where((element) => element.count > 0)
              .toList()
          : null,
      trailing: axis == Axis.horizontal
          ? ButtonBar(
              children: [
                PostGridConfigIconButton(
                  postController: controller,
                ),
              ],
            )
          : null,
      onClosed: () {
        ref.setPostListConfigHeaderStatus(
          active: false,
        );
        showSimpleSnackBar(
          duration: const Duration(seconds: 5),
          context: context,
          content:
              const Text('You can always show this header again in Settings.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => ref.setPostListConfigHeaderStatus(active: true),
          ),
        );
      },
      onDisableAll: _disableAll,
      onEnableAll: _enableAll,
      onChanged: _update,
      hiddenCount: filteredItems.length,
    );
  }

  void _update(tag, hide) {
    setState(() {
      filters[tag] = hide;
      _updateData(
        filters: filters,
        bustCache: true,
      );
    });
  }

  void _enableAll() {
    setState(() {
      filters = filters.map(
        (key, value) => MapEntry(key, true),
      );
      _updateData(
        filters: filters,
        bustCache: true,
      );
    });
  }

  void _disableAll() {
    setState(() {
      filters = filters.map(
        (key, value) => MapEntry(key, false),
      );
      _updateData(
        filters: filters,
        bustCache: true,
      );
    });
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
