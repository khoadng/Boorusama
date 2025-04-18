// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../analytics.dart';
import '../../../../boorus/booru/booru.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../posts/count/widgets.dart';
import '../../../../posts/listing/providers.dart';
import '../../../../posts/listing/widgets.dart';
import '../../../../posts/post/post.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../tags/configs/providers.dart';
import '../../../../utils/stream/text_editing_controller_utils.dart';
import '../../../../widgets/widgets.dart';
import '../../../histories/providers.dart';
import '../../../selected_tags/selected_tag_controller.dart';
import '../../../selected_tags/tag.dart';
import '../../../suggestions/suggestions_notifier.dart';
import '../../../suggestions/tag_suggestion_items.dart';
import '../pages/search_page.dart';
import '../views/search_landing_view.dart';
import 'search_app_bar.dart';
import 'search_button.dart';
import 'search_controller.dart';
import 'selected_tag_list_with_data.dart';

typedef IndexedSelectableSearchWidgetBuilder<T extends Post> = Widget Function(
  BuildContext context,
  int index,
  MultiSelectController<T> multiSelectController,
  AutoScrollController autoScrollController,
  PostGridController<T> controller,
  bool useHero,
);

const _kSearchBarHeight = kToolbarHeight * 1.2;
const _kSelectedTagHeight = 48.0;
const _kViewTopPadding = 8.0;
const _kMultiSelectTopHeight = kToolbarHeight;

double _calcBaseSearchHeight(List<TagSearchItem> tags) {
  return _kSearchBarHeight + (tags.isNotEmpty ? _kSelectedTagHeight : 0);
}

double _calcSearchRegionHeight(List<TagSearchItem> selectedTags) {
  return _calcBaseSearchHeight(selectedTags);
}

class SearchPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const SearchPageScaffold({
    required this.fetcher,
    required this.params,
    super.key,
    this.noticeBuilder,
    this.queryPattern,
    this.metatags,
    this.trending,
    this.extraHeaders,
    this.itemBuilder,
  });

  final SearchParams params;

  String? get initialQuery => params.initialQuery;
  int? get initialPage => params.initialPage;
  int? get initialScrollPosition => params.initialScrollPosition;

  final Widget Function(BuildContext context)? noticeBuilder;

  final List<Widget> Function(
    BuildContext context,
    PostGridController<T> postController,
  )? extraHeaders;

  final PostsOrErrorCore<T> Function(
    int page,
    SelectedTagController selectedTagController,
  ) fetcher;

  final Map<RegExp, TextStyle>? queryPattern;

  final IndexedSelectableSearchWidgetBuilder<T>? itemBuilder;

  final Widget? Function(BuildContext context, SearchPageController controller)?
      metatags;
  final Widget? Function(BuildContext context, SearchPageController controller)?
      trending;

  @override
  ConsumerState<SearchPageScaffold<T>> createState() =>
      _SearchPageScaffoldState<T>();
}

class _SearchPageScaffoldState<T extends Post>
    extends ConsumerState<SearchPageScaffold<T>>
    with SingleTickerProviderStateMixin {
  late final SelectedTagController _tagsController;
  final _scrollController = AutoScrollController();

  final CompositeSubscription _subscriptions = CompositeSubscription();
  late final SearchPageController _controller;

  late final _searchBarAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  final _multiSelectController = MultiSelectController<T>();

  var _hasScrolledToInitialPosition = false;

  @override
  void initState() {
    super.initState();

    _tagsController = SelectedTagController.fromBooruBuilder(
      builder: ref.read(currentBooruBuilderProvider),
      tagInfo: ref.read(tagInfoProvider),
    );

    _controller = SearchPageController(
      onSearch: () {
        ref
            .read(searchHistoryProvider.notifier)
            .addHistoryFromController(_tagsController);
      },
      queryPattern: widget.queryPattern,
      tagsController: _tagsController,
    );
    if (widget.initialPage != null) {
      _controller.skipToResultWithTag('');
    } else if (widget.initialQuery != null) {
      _controller.skipToResultWithTag(
        widget.initialQuery!,
        queryType: widget.params.initialQueryType,
      );
      ref
          .read(searchHistoryProvider.notifier)
          .addHistoryFromController(_tagsController);
    }

    _controller.textController.textAsStream().pairwise().listen((pair) {
      _onQueryChanged(pair.first, pair.last);
    }).addTo(_subscriptions);

    _tagsController.addListener(_onSelectedTagChanged);
    _controller.tagString.addListener(_onTagChanged);

    _previousMultiSelectState = _multiSelectController.multiSelectEnabled;
    _multiSelectController.multiSelectNotifier
        .addListener(_onMultiSelectChanged);
  }

  void _onMultiSelectChanged() {
    final currentSelected = _multiSelectController.multiSelectEnabled;

    if (_previousMultiSelectState != currentSelected) {
      final currentOffset = _scrollController.offset;
      final offsetSearchHeight = _calcSearchRegionHeight(_tagsController.value);
      final sign = currentSelected ? -1 : 1;
      final jumpTo =
          (currentOffset + sign * (offsetSearchHeight + _kMultiSelectTopHeight))
              .clamp(0, double.infinity)
              .toDouble();

      // Scroll backward to compensate for the change in height
      _scrollController.jumpTo(jumpTo);

      _previousMultiSelectState = currentSelected;
    }
  }

  var _searchBarOffset = 0.0;

  late bool? _previousMultiSelectState;

  void _onTagChanged() {
    // check if scroll controller is attached
    if (_scrollController.hasClients) {
      // scroll to top when tag is added
      _scrollController.jumpTo(0);
    }
  }

  void _onQueryChanged(String previous, String current) {
    if (previous == current) {
      return;
    }

    _controller.onQueryChanged(current);

    ref
        .read(suggestionsNotifierProvider(ref.readConfigAuth).notifier)
        .getSuggestions(current);
  }

  void _onSelectedTagChanged() {
    _controller.allowSearch.value = _tagsController.rawTags.isNotEmpty;
  }

  @override
  void dispose() {
    _tagsController.removeListener(_onSelectedTagChanged);
    _controller.tagString.removeListener(_onTagChanged);
    _multiSelectController.multiSelectNotifier
        .removeListener(_onMultiSelectChanged);

    _subscriptions.dispose();
    _controller.dispose();
    _tagsController.dispose();
    _scrollController.dispose();
    _searchBarAnimController.dispose();
    _multiSelectController.dispose();

    super.dispose();
  }

  PostGridController<T>? _postController;

  void _setupPostControllerListener(PostGridController<T> controller) {
    if (_postController != controller) {
      if (widget.initialScrollPosition != null) {
        controller.events.listen((event) {
          if (event is PostControllerRefreshCompleted &&
              !_hasScrolledToInitialPosition &&
              widget.initialScrollPosition != null) {
            _scrollController.scrollToIndex(
              widget.initialScrollPosition!,
            );
            _hasScrolledToInitialPosition = true;
          }
        });
      }

      _postController = controller;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomContextMenuOverlay(
      child: InheritedSearchPageController(
        controller: _controller,
        child: ColoredBox(
          color: colorScheme.surface,
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                ValueListenableBuilder(
                  valueListenable: _controller.didSearchOnce,
                  builder: (context, searchOnce, child) {
                    return searchOnce
                        ? _buildResult()
                        : _Landing(
                            metatags: widget.metatags,
                            trending: widget.trending,
                            searchBarAnimController: _searchBarAnimController,
                            multiSelectController: _multiSelectController,
                          );
                  },
                ),
                _SearchOptionsView(
                  metatags: widget.metatags,
                  searchBarAnimController: _searchBarAnimController,
                  multiSelectController: _multiSelectController,
                ),
                _SearchSuggestions(
                  searchBarAnimController: _searchBarAnimController,
                  multiSelectController: _multiSelectController,
                ),
                _SearchBarPositioned(
                  multiSelectController: _multiSelectController,
                  searchBarAnimController: _searchBarAnimController,
                  child: _SearchRegion(
                    onSearch: () {
                      _controller.search();
                      _postController?.refresh();
                      _controller.focus.unfocus();
                    },
                    initialQuery: widget.initialQuery,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final persistentSearchBar = ref.watch(
      settingsProvider.select((value) => value.persistSearchBar),
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (persistentSearchBar) return false;
        if (notification.depth != 0) return false;

        final viewPadding = _kSearchBarPosition == SearchBarPosition.bottom
            ? MediaQuery.viewPaddingOf(context).bottom
            : _kViewTopPadding;

        final searchRegionHeight =
            _calcSearchRegionHeight(_tagsController.value) + viewPadding;

        final pixels = notification.metrics.pixels;

        if (notification is ScrollUpdateNotification) {
          // Ignore overscroll
          // Also must scroll pass the search bar
          if (pixels <= 0) {
            return false;
          }

          final newValue = _searchBarOffset + (notification.scrollDelta ?? 0);

          _searchBarOffset = newValue.clamp(0, searchRegionHeight);

          _searchBarAnimController.value =
              _searchBarOffset / searchRegionHeight;
        } else if (notification is ScrollEndNotification) {
          final pixels = notification.metrics.pixels;

          final offset = _searchBarOffset.abs();

          final isHalf = offset > searchRegionHeight / 2;

          _searchBarOffset = isHalf ? searchRegionHeight : 0.0;

          // Handle case where user taps on jump to top button
          if (pixels < searchRegionHeight) {
            _searchBarAnimController.reverse();
            _searchBarOffset = 0;
          } else if (isHalf) {
            _searchBarAnimController.forward();
            _searchBarOffset = searchRegionHeight;
          } else {
            _searchBarAnimController.reverse();
            _searchBarOffset = 0;
          }
        }

        return true;
      },
      child: PostScope(
        fetcher: (page) => widget.fetcher(
          page,
          _controller.tagsController,
        ),
        pageMode: widget.initialPage != null ? PageMode.paginated : null,
        initialPage: widget.initialPage,
        builder: (context, controller) {
          // Hacky way to get the controller
          _setupPostControllerListener(controller);
          return _buildDefaultSearchResults(
            context,
            controller,
          );
        },
      ),
    );
  }

  Widget _buildDefaultSearchResults(
    BuildContext context,
    PostGridController<T> controller,
  ) {
    return _SearchRegionSafeArea(
      searchBarAnimController: _searchBarAnimController,
      multiSelectController: _multiSelectController,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          bottom: false,
          child: PostGrid<T>(
            multiSelectController: _multiSelectController,
            scrollController: _scrollController,
            controller: controller,
            itemBuilder: widget.itemBuilder != null
                ? (
                    context,
                    index,
                    multiSelectController,
                    scrollController,
                    useHero,
                  ) {
                    return widget.itemBuilder!(
                      context,
                      index,
                      multiSelectController,
                      _scrollController,
                      controller,
                      useHero,
                    );
                  }
                : null,
            sliverHeaders: [
              const SearchResultAnalyticsAnchor(),
              if (widget.extraHeaders != null)
                ...widget.extraHeaders!(
                  context,
                  controller,
                ),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _controller.tagString,
                      builder: (context, value, _) =>
                          ResultHeaderFromController(
                        controller: controller,
                        onRefresh: null,
                        hasCount:
                            ref.watchConfigAuth.booruType.postCountMethod ==
                                PostCountMethod.search,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchRegionSafeArea extends StatelessWidget {
  const _SearchRegionSafeArea({
    required this.child,
    required this.searchBarAnimController,
    required this.multiSelectController,
  });

  final Widget child;
  final AnimationController searchBarAnimController;
  final MultiSelectController multiSelectController;

  @override
  Widget build(BuildContext context) {
    final displacement = _Displacement(
      searchBarAnimController: searchBarAnimController,
      multiSelectController: multiSelectController,
    );

    return Column(
      children: [
        if (_kSearchBarPosition == SearchBarPosition.top) displacement,
        Expanded(
          child: child,
        ),
        if (_kSearchBarPosition == SearchBarPosition.bottom) displacement,
      ],
    );
  }
}

class _SearchRegion extends ConsumerWidget {
  const _SearchRegion({
    required this.onSearch,
    this.initialQuery,
  });

  final VoidCallback onSearch;
  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = InheritedSearchPageController.of(context);
    final tagsController = controller.tagsController;
    final theme = Theme.of(context);
    final parentRoute = ModalRoute.of(context);
    final autoFocusSearchBar = ref.read(
      settingsProvider.select((value) => value.autoFocusSearchBar),
    );

    final children = [
      SizedBox(
        height: _kSearchBarHeight,
        child: MultiValueListenableBuilder2(
          first: controller.state,
          second: controller.didSearchOnce,
          builder: (_, state, searchOnce) {
            return SearchAppBar(
              onTapOutside: _kSearchBarPosition == SearchBarPosition.bottom &&
                      searchOnce &&
                      state == SearchState.initial
                  ? null
                  // When search bar is at the bottom, keyboard will be kept open for better UX unless the app switches to results
                  : () {},
              onSubmitted: (value) => controller.submit(value),
              trailingSearchButton: _buildTrailingButton(context),
              innerSearchButton: _buildSearchButton(context),
              focusNode: controller.focus,
              autofocus: initialQuery == null ? autoFocusSearchBar : false,
              controller: controller.textController,
              leading: (parentRoute?.impliesAppBarDismissal ?? false)
                  ? const SearchAppBarBackButton()
                  : null,
            );
          },
        ),
      ),
      SelectedTagListWithData(controller: tagsController),
    ];

    final region = ColoredBox(
      color: theme.colorScheme.surface,
      child: Column(
        children: switch (_kSearchBarPosition) {
          SearchBarPosition.top => children,
          SearchBarPosition.bottom => children.reversed.toList(),
        },
      ),
    );

    return _kSearchBarPosition == SearchBarPosition.top
        ? region
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              region,
              const _SearchRegionBottomDisplacement(),
            ],
          );
  }

  Widget _buildTrailingButton(BuildContext context) {
    final controller = InheritedSearchPageController.of(context);

    return ValueListenableBuilder(
      valueListenable: controller.didSearchOnce,
      builder: (_, searchOnce, __) {
        return !searchOnce
            ? const SizedBox.shrink()
            : ValueListenableBuilder(
                valueListenable: controller.state,
                builder: (_, state, __) => state != SearchState.suggestions
                    ? AnimatedRotation(
                        duration: const Duration(milliseconds: 150),
                        turns: state == SearchState.options ? 0.13 : 0,
                        child: IconButton(
                          iconSize: 28,
                          onPressed: () {
                            if (state != SearchState.options) {
                              controller.changeState(SearchState.options);
                            } else {
                              controller.changeState(SearchState.initial);
                            }
                          },
                          icon: const Icon(Symbols.add),
                        ),
                      )
                    : const SizedBox.shrink(),
              );
      },
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    final controller = InheritedSearchPageController.of(context);

    return MultiValueListenableBuilder2(
      first: controller.allowSearch,
      second: controller.didSearchOnce,
      builder: (context, allowSearch, searchOnce) {
        final searchButton = Padding(
          padding: const EdgeInsets.only(
            right: 8,
          ),
          child: SearchButton2(
            onTap: onSearch,
          ),
        );
        return searchOnce
            ? searchButton
            : AnimatedOpacity(
                opacity: allowSearch ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedScale(
                  scale: allowSearch ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  alignment: Alignment.center,
                  child: searchButton,
                ),
              );
      },
    );
  }
}

class _SearchRegionBottomDisplacement extends StatelessWidget {
  const _SearchRegionBottomDisplacement();

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final viewPadding = MediaQuery.viewPaddingOf(context).bottom;

    return SizedBox(
      height: max(viewInsets, viewPadding),
    );
  }
}

enum SearchBarPosition {
  top,
  bottom,
}

const _kSearchBarPosition = SearchBarPosition.top;

class _SearchBarPositioned extends StatefulWidget {
  const _SearchBarPositioned({
    required this.searchBarAnimController,
    required this.multiSelectController,
    required this.child,
  });

  final Widget child;
  final AnimationController searchBarAnimController;
  final MultiSelectController multiSelectController;

  @override
  State<_SearchBarPositioned> createState() => _SearchBarPositionedState();
}

class _SearchBarPositionedState extends State<_SearchBarPositioned> {
  late final _searchBarCurve = CurvedAnimation(
    parent: widget.searchBarAnimController,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _searchBarCurve.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = InheritedSearchPageController.of(context);

    return MultiValueListenableBuilder4(
      first: controller.didSearchOnce,
      second: controller.state,
      third: controller.tagsController,
      fourth: widget.multiSelectController.multiSelectNotifier,
      builder: (_, searchOnce, state, selectedTags, multiSelect) {
        final baseSearchRegionHeight = _calcSearchRegionHeight(selectedTags);
        final viewPadding = _kSearchBarPosition == SearchBarPosition.bottom
            ? MediaQuery.viewPaddingOf(context).bottom
            : 0;
        final searchRegionHeight = baseSearchRegionHeight + viewPadding;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) => true,
          child: AnimatedBuilder(
            animation: _searchBarCurve,
            builder: (context, _) {
              final padding = multiSelect
                  ? -searchRegionHeight
                  : searchOnce
                      ? state == SearchState.suggestions
                          ? 0.0
                          : -(_searchBarCurve.value * searchRegionHeight)
                      : 0.0;

              return Positioned(
                bottom: _kSearchBarPosition == SearchBarPosition.bottom
                    ? padding
                    : null,
                top: _kSearchBarPosition == SearchBarPosition.top
                    ? padding
                    : null,
                left: 0,
                right: 0,
                child: widget.child,
              );
            },
          ),
        );
      },
    );
  }
}

class _Displacement extends StatefulWidget {
  const _Displacement({
    required this.searchBarAnimController,
    required this.multiSelectController,
  });

  final AnimationController searchBarAnimController;
  final MultiSelectController multiSelectController;

  @override
  State<_Displacement> createState() => __DisplacementState();
}

class __DisplacementState extends State<_Displacement> {
  late final _searchBarCurve = CurvedAnimation(
    parent: widget.searchBarAnimController,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _searchBarCurve.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = InheritedSearchPageController.of(context);

    return MultiValueListenableBuilder4(
      first: controller.tagsController,
      second: controller.state,
      third: controller.didSearchOnce,
      fourth: widget.multiSelectController.multiSelectNotifier,
      builder: (_, value, state, searchOnce, multiSelect) {
        if (multiSelect) {
          return const SizedBox.shrink();
        }

        final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
        final viewPadding = MediaQuery.viewPaddingOf(context).bottom;
        final padding = max(viewInsets, viewPadding);

        final effectivePadding = searchOnce
            ? state != SearchState.suggestions && state != SearchState.options
                ? 0
                : padding
            : padding;

        final baseHeight = _kSearchBarPosition == SearchBarPosition.bottom
            ? effectivePadding + _calcBaseSearchHeight(value)
            : _kViewTopPadding + _calcBaseSearchHeight(value);

        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _searchBarCurve,
            builder: (context, _) {
              return SizedBox(
                height: baseHeight * (1 - _searchBarCurve.value),
              );
            },
          ),
        );
      },
    );
  }
}

class _Landing extends StatelessWidget {
  const _Landing({
    required this.metatags,
    required this.trending,
    required this.searchBarAnimController,
    required this.multiSelectController,
  });

  final Widget? Function(
    BuildContext context,
    SearchPageController controller,
  )? metatags;

  final Widget? Function(
    BuildContext context,
    SearchPageController controller,
  )? trending;

  final AnimationController searchBarAnimController;
  final MultiSelectController multiSelectController;

  @override
  Widget build(BuildContext context) {
    final controller = InheritedSearchPageController.of(context);

    return _SearchRegionSafeArea(
      searchBarAnimController: searchBarAnimController,
      multiSelectController: multiSelectController,
      child: SearchLandingView(
        reverse: _kSearchBarPosition == SearchBarPosition.bottom,
        onHistoryTap: (value) {
          controller.tapHistoryTag(value);
        },
        onFavTagTap: (value) {
          controller.tapFavTag(value);
        },
        onRawTagTap: (value) => controller.tagsController.addTag(
          value,
          isRaw: true,
        ),
        metatags: metatags?.call(context, controller),
        trending: trending?.call(context, controller),
      ),
    );
  }
}

class _SearchSuggestions extends ConsumerWidget {
  const _SearchSuggestions({
    required this.searchBarAnimController,
    required this.multiSelectController,
  });

  final AnimationController searchBarAnimController;
  final MultiSelectController multiSelectController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = InheritedSearchPageController.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return _SearchRegionSafeArea(
      searchBarAnimController: searchBarAnimController,
      multiSelectController: multiSelectController,
      child: MultiValueListenableBuilder2(
        first: controller.state,
        second: controller.didSearchOnce,
        builder: (_, state, searchOnce) => state == SearchState.suggestions
            ? ColoredBox(
                color: colorScheme.surface,
                child: Column(
                  children: [
                    ref.watch(analyticsProvider).maybeWhen(
                          data: (analytics) => SearchViewAnalyticsAnchor(
                            routeName: '/search_suggestions',
                            previousRoute: !searchOnce
                                ? ModalRoute.of(context)?.settings
                                : const RouteSettings(name: '/search_result'),
                            analytics: analytics,
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: controller.textController,
                        builder: (context, query, child) {
                          final suggestionTags =
                              ref.watch(suggestionProvider(query.text));

                          return TagSuggestionItems(
                            reverse:
                                _kSearchBarPosition == SearchBarPosition.bottom,
                            config: ref.watchConfigAuth,
                            tags: suggestionTags,
                            currentQuery: query.text,
                            onItemTap: (tag) {
                              controller.tapTag(tag.value);
                            },
                            emptyBuilder: () => Center(
                              child: ColoredBox(
                                color: colorScheme.surface,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _SearchOptionsView extends ConsumerWidget {
  const _SearchOptionsView({
    required this.metatags,
    required this.searchBarAnimController,
    required this.multiSelectController,
  });

  final Widget? Function(BuildContext context, SearchPageController controller)?
      metatags;
  final AnimationController searchBarAnimController;
  final MultiSelectController multiSelectController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = InheritedSearchPageController.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return _SearchRegionSafeArea(
      searchBarAnimController: searchBarAnimController,
      multiSelectController: multiSelectController,
      child: ValueListenableBuilder(
        valueListenable: controller.state,
        builder: (context, state, child) => state == SearchState.options
            ? ColoredBox(
                color: colorScheme.surface,
                child: Column(
                  children: [
                    ref.watch(analyticsProvider).maybeWhen(
                          data: (analytics) => SearchViewAnalyticsAnchor(
                            routeName: '/search_options',
                            previousRoute: const RouteSettings(
                              name: '/search_result',
                            ),
                            analytics: analytics,
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                    Expanded(
                      child: child!,
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
        child: SearchLandingView(
          reverse: _kSearchBarPosition == SearchBarPosition.bottom,
          scrollController: ModalScrollController.of(
            context,
          ),
          onHistoryTap: (value) {
            controller.tapHistoryTag(
              value,
            );
          },
          onFavTagTap: (value) {
            controller.tapFavTag(value);
          },
          onRawTagTap: (value) {
            controller.tagsController.addTag(
              value,
              isRaw: true,
            );
          },
          metatags: metatags?.call(
            context,
            controller,
          ),
        ),
      ),
    );
  }
}

class SearchResultAnalyticsAnchor extends ConsumerStatefulWidget {
  const SearchResultAnalyticsAnchor({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SearchResultAnalyticsAnchorState();
}

class _SearchResultAnalyticsAnchorState
    extends ConsumerState<SearchResultAnalyticsAnchor> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).whenData(
          (analytics) => analytics.logScreenView('/search_result'),
        );
  }

  @override
  Widget build(BuildContext context) {
    return const SliverSizedBox.shrink();
  }
}

class SearchViewAnalyticsAnchor extends ConsumerStatefulWidget {
  const SearchViewAnalyticsAnchor({
    required this.routeName,
    required this.previousRoute,
    required this.analytics,
    super.key,
  });

  final String routeName;

  final RouteSettings? previousRoute;
  final AnalyticsInterface analytics;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SuggestionViewAnalyticsAnchoreState();
}

class _SuggestionViewAnalyticsAnchoreState
    extends ConsumerState<SearchViewAnalyticsAnchor> {
  @override
  void initState() {
    super.initState();
    widget.analytics.logScreenView(widget.routeName);
  }

  @override
  void dispose() {
    final name = widget.previousRoute?.name;

    if (name != null) {
      widget.analytics.logScreenView(name);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
