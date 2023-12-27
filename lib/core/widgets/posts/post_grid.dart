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
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/posts/post_grid_config_region.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'post_grid_config_icon_button.dart';
import 'post_grid_controller.dart';
import 'post_list_configuration_header.dart';

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
    this.blacklistedTags = const {},
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

  final Set<String> blacklistedTags;

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
  var tagCounts = <String, int>{};
  var _hasBlacklistedTags = false;

  @override
  void didUpdateWidget(PostGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blacklistedTags != widget.blacklistedTags) {
      _updateFilter();
      _updateData();
    }
  }

  void _updateFilter() {
    setState(() {
      filters = {
        for (final tag in widget.blacklistedTags) tag: true,
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

  void _updateData() {
    final d = filter(
      controller.items,
      [
        for (final tag in filters.keys)
          if (filters[tag]!) tag
      ],
    );
    items = d.data;
    filteredItems = d.filtered;
  }

  void _countTags() {
    tagCounts = controller.items.countTagPattern(widget.blacklistedTags);
    _hasBlacklistedTags = tagCounts.values.any((c) => c > 0);
  }

  void _onControllerChange() {
    if (!mounted) return;
    setState(() {
      _updateData();
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: header,
                                  ),
                                ),
                            const SliverSizedBox(
                              height: 4,
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
                            if (pageMode == PageMode.paginated)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: PageSelector(
                                    currentPage: page,
                                    onPrevious: controller.hasPreviousPage()
                                        ? () => controller.goToPreviousPage()
                                        : null,
                                    onNext: controller.hasNextPage()
                                        ? () => controller.goToNextPage()
                                        : null,
                                    onPageSelect: (page) =>
                                        controller.jumpToPage(page),
                                  ),
                                ),
                              ),
                          ],
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

  Widget _buildConfigHeader(Axis axis) {
    return PostListConfigurationHeader(
      axis: axis,
      postCount: items.length + filteredItems.length,
      initiallyExpanded: axis == Axis.vertical,
      hasBlacklist: _hasBlacklistedTags,
      tags: widget.blacklistedTags
          .map((e) => (
                name: e,
                count: tagCounts[e] ?? 0,
                active: filters[e] ?? false,
              ))
          .where((element) => element.count > 0)
          .toList(),
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
      _updateData();
    });
  }

  void _enableAll() {
    setState(() {
      filters = filters.map(
        (key, value) => MapEntry(key, true),
      );
      _updateData();
    });
  }

  void _disableAll() {
    setState(() {
      filters = filters.map(
        (key, value) => MapEntry(key, false),
      );
      _updateData();
    });
  }

  void _onWillPop() {
    if (multiSelect) {
      _multiSelectController.disableMultiSelect();
    } else {
      context.pop();
    }
  }
}
