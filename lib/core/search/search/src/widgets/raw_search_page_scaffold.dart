// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../analytics.dart';
import '../../../../posts/listing/providers.dart';
import '../../../../posts/listing/widgets.dart';
import '../../../../posts/post/post.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../utils/stream/text_editing_controller_utils.dart';
import '../../../../widgets/widgets.dart';
import '../../../histories/providers.dart';
import '../../../selected_tags/selected_tag_controller.dart';
import '../../../selected_tags/tag.dart';
import '../pages/search_page.dart';
import 'search_controller.dart';

typedef IndexedSelectableSearchWidgetBuilder<T extends Post> = Widget Function(
  BuildContext context,
  int index,
  MultiSelectController multiSelectController,
  AutoScrollController autoScrollController,
  PostGridController<T> controller,
  bool useHero,
);

const kSearchBarHeight = kToolbarHeight;
const _kSelectedTagHeight = 48.0;
const _kMultiSelectTopHeight = kToolbarHeight;

double _calcBaseSearchHeight(List<TagSearchItem> tags) {
  return kSearchBarHeight + (tags.isNotEmpty ? _kSelectedTagHeight : 0);
}

double _calcSearchRegionHeight(List<TagSearchItem> selectedTags) {
  return _calcBaseSearchHeight(selectedTags);
}

class RawSearchPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const RawSearchPageScaffold({
    required this.fetcher,
    required this.params,
    required this.tagsController,
    required this.controller,
    required this.multiSelectController,
    required this.onQueryChanged,
    required this.searchRegion,
    required this.searchSuggestions,
    required this.resultHeader,
    required this.onPostControllerCreated,
    required this.landingView,
    super.key,
    this.noticeBuilder,
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

  final IndexedSelectableSearchWidgetBuilder<T>? itemBuilder;

  final Widget landingView;

  final SelectedTagController tagsController;
  final SearchPageController controller;
  final MultiSelectController multiSelectController;
  final void Function(String value) onQueryChanged;
  final Widget searchRegion;
  final Widget searchSuggestions;
  final Widget resultHeader;
  final void Function(PostGridController<T> controller) onPostControllerCreated;

  @override
  ConsumerState<RawSearchPageScaffold<T>> createState() =>
      _SearchPageScaffoldState<T>();
}

class _SearchPageScaffoldState<T extends Post>
    extends ConsumerState<RawSearchPageScaffold<T>>
    with SingleTickerProviderStateMixin {
  SelectedTagController get _tagsController => widget.tagsController;
  final _scrollController = AutoScrollController();

  final CompositeSubscription _subscriptions = CompositeSubscription();
  SearchPageController get _controller => widget.controller;

  late final _searchBarAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  MultiSelectController get _multiSelectController =>
      widget.multiSelectController;

  var _hasScrolledToInitialPosition = false;

  @override
  void initState() {
    super.initState();

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

    widget.onQueryChanged(current);
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
    _scrollController.dispose();
    _searchBarAnimController.dispose();

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
      widget.onPostControllerCreated(controller);
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
                            landingView: widget.landingView,
                            multiSelectController: _multiSelectController,
                          );
                  },
                ),
                _SearchOptionsView(
                  landingView: widget.landingView,
                  multiSelectController: _multiSelectController,
                ),
                widget.searchSuggestions,
                _SearchBarPositioned(
                  multiSelectController: _multiSelectController,
                  searchBarAnimController: _searchBarAnimController,
                  child: widget.searchRegion,
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
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (persistentSearchBar) return false;
        if (notification.depth != 0) return false;

        final viewPadding = searchBarPosition == SearchBarPosition.bottom
            ? MediaQuery.viewPaddingOf(context).bottom
            : 0;

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
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    return ColoredBox(
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
          scrollToTopButton: ValueListenableBuilder(
            valueListenable: _tagsController,
            builder: (_, tags, __) {
              return _ScrollToTopButtonPadding(
                multiSelectController: _multiSelectController,
                searchBarAnimController: _searchBarAnimController,
                builder: (context, value) {
                  return PostGridScrollToTopButton(
                    controller: controller,
                    multiSelectController: _multiSelectController,
                    autoScrollController: _scrollController,
                    bottomPadding: (1 - value) * _calcSearchRegionHeight(tags),
                  );
                },
              );
            },
          ),
          sliverHeaders: [
            if (searchBarPosition == SearchBarPosition.top)
              SliverToBoxAdapter(
                child: _Displacement(
                  multiSelectController: _multiSelectController,
                ),
              ),
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
                  widget.resultHeader,
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchRegionSafeArea extends ConsumerWidget {
  const SearchRegionSafeArea({
    required this.child,
    required this.multiSelectController,
    super.key,
  });

  final Widget child;
  final MultiSelectController multiSelectController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displacement = _Displacement(
      multiSelectController: multiSelectController,
    );
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    return Column(
      children: [
        if (searchBarPosition == SearchBarPosition.top) displacement,
        Expanded(
          child: child,
        ),
        if (searchBarPosition == SearchBarPosition.bottom) displacement,
      ],
    );
  }
}

class _ScrollToTopButtonPadding extends ConsumerStatefulWidget {
  const _ScrollToTopButtonPadding({
    required this.builder,
    required this.searchBarAnimController,
    required this.multiSelectController,
  });

  final Widget Function(
    BuildContext context,
    double value,
  ) builder;

  final AnimationController searchBarAnimController;
  final MultiSelectController multiSelectController;

  @override
  ConsumerState<_ScrollToTopButtonPadding> createState() =>
      __ScrollToTopButtonPaddingState();
}

class __ScrollToTopButtonPaddingState
    extends ConsumerState<_ScrollToTopButtonPadding> {
  late final CurvedAnimation _animation = CurvedAnimation(
    parent: widget.searchBarAnimController,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _animation.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    return ValueListenableBuilder(
      valueListenable: widget.multiSelectController.multiSelectNotifier,
      builder: (_, multiSelect, __) {
        if (multiSelect || searchBarPosition == SearchBarPosition.top) {
          return widget.builder(context, 1);
        }

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return widget.builder(
              context,
              _animation.value,
            );
          },
        );
      },
    );
  }
}

class _SearchBarPositioned extends ConsumerStatefulWidget {
  const _SearchBarPositioned({
    required this.searchBarAnimController,
    required this.multiSelectController,
    required this.child,
  });

  final Widget child;
  final AnimationController searchBarAnimController;
  final MultiSelectController multiSelectController;

  @override
  ConsumerState<_SearchBarPositioned> createState() =>
      __SearchBarPositionedState();
}

class __SearchBarPositionedState extends ConsumerState<_SearchBarPositioned> {
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
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    return MultiValueListenableBuilder4(
      first: controller.didSearchOnce,
      second: controller.state,
      third: controller.tagsController,
      fourth: widget.multiSelectController.multiSelectNotifier,
      builder: (_, searchOnce, state, selectedTags, multiSelect) {
        final baseSearchRegionHeight = _calcSearchRegionHeight(selectedTags);
        final viewPadding = searchBarPosition == SearchBarPosition.bottom
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
                bottom: searchBarPosition == SearchBarPosition.bottom
                    ? padding
                    : null,
                top:
                    searchBarPosition == SearchBarPosition.top ? padding : null,
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

class _Displacement extends ConsumerWidget {
  const _Displacement({
    required this.multiSelectController,
  });

  final MultiSelectController multiSelectController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = InheritedSearchPageController.of(context);
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    return MultiValueListenableBuilder4(
      first: controller.tagsController,
      second: controller.state,
      third: controller.didSearchOnce,
      fourth: multiSelectController.multiSelectNotifier,
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

        final baseHeight = searchBarPosition == SearchBarPosition.bottom
            ? effectivePadding + _calcBaseSearchHeight(value)
            : _calcBaseSearchHeight(value);

        return SizedBox(
          height: baseHeight,
        );
      },
    );
  }
}

class _Landing extends ConsumerWidget {
  const _Landing({
    required this.landingView,
    required this.multiSelectController,
  });

  final Widget landingView;
  final MultiSelectController multiSelectController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchRegionSafeArea(
      multiSelectController: multiSelectController,
      child: landingView,
    );
  }
}

class _SearchOptionsView extends ConsumerWidget {
  const _SearchOptionsView({
    required this.landingView,
    required this.multiSelectController,
  });

  final Widget landingView;
  final MultiSelectController multiSelectController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = InheritedSearchPageController.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SearchRegionSafeArea(
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
        child: landingView,
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
