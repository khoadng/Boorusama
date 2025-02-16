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
import '../../../../tags/configs/providers.dart';
import '../../../../utils/stream/text_editing_controller_utils.dart';
import '../../../../widgets/widgets.dart';
import '../../../histories/providers.dart';
import '../../../selected_tags/selected_tag_controller.dart';
import '../../../suggestions/suggestions_notifier.dart';
import '../../../suggestions/tag_suggestion_items.dart';
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
const _kSelectedTagHeight = 56;
const _kViewTopPadding = 8;

class SearchPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const SearchPageScaffold({
    required this.fetcher,
    super.key,
    this.initialQuery,
    this.noticeBuilder,
    this.queryPattern,
    this.metatags,
    this.trending,
    this.extraHeaders,
    this.itemBuilder,
  });

  final String? initialQuery;

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

  late final _searchBarCurve = CurvedAnimation(
    parent: _searchBarAnimController,
    curve: Curves.easeInOut,
  );

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

    if (widget.initialQuery != null) {
      _controller.skipToResultWithTag(widget.initialQuery!);
      ref
          .read(searchHistoryProvider.notifier)
          .addHistoryFromController(_tagsController);
    }

    _controller.textController.textAsStream().pairwise().listen((pair) {
      _onQueryChanged(pair.first, pair.last);
    }).addTo(_subscriptions);

    _tagsController.addListener(_onSelectedTagChanged);
    _controller.tagString.addListener(_onTagChanged);
  }

  var _searchBarOffset = 0.0;

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

    _subscriptions.dispose();
    _controller.dispose();
    _tagsController.dispose();
    _scrollController.dispose();
    _searchBarAnimController.dispose();
    _searchBarCurve.dispose();

    super.dispose();
  }

  PostGridController<T>? _postController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final persistentSearchBar = ref.watch(
      settingsProvider.select((value) => value.persistSearchBar),
    );

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
                        ? NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (persistentSearchBar) return false;
                              if (notification.depth != 0) return false;

                              final hasSelectedTag =
                                  _tagsController.value.isNotEmpty;

                              final searchRegionHeight = _kSearchBarHeight +
                                  (hasSelectedTag ? _kSelectedTagHeight : 0);

                              final pixels = notification.metrics.pixels;

                              if (notification is ScrollUpdateNotification) {
                                // Ignore overscroll
                                // Also must scroll pass the search bar
                                if (pixels <= 0) {
                                  return false;
                                }

                                final newValue = _searchBarOffset +
                                    (notification.scrollDelta ?? 0);

                                _searchBarOffset =
                                    newValue.clamp(0, searchRegionHeight);

                                _searchBarAnimController.value =
                                    _searchBarOffset / searchRegionHeight;
                              } else if (notification
                                  is ScrollEndNotification) {
                                final pixels = notification.metrics.pixels;

                                final offset = _searchBarOffset.abs();

                                final isHalf = offset > searchRegionHeight / 2;

                                _searchBarOffset =
                                    isHalf ? searchRegionHeight : 0.0;

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
                              builder: (context, controller) {
                                // Hacky way to get the controller
                                _postController = controller;
                                return _buildDefaultSearchResults(
                                  context,
                                  controller,
                                );
                              },
                            ),
                          )
                        : _buildInitial(context);
                  },
                ),
                _SearchOptionsView(
                  metatags: widget.metatags,
                ),
                _buildSuggestions(context),
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    return true;
                  },
                  child: AnimatedBuilder(
                    animation: _searchBarCurve,
                    builder: (context, child) {
                      return ValueListenableBuilder(
                        valueListenable: _controller.didSearchOnce,
                        builder: (_, searchOnce, __) {
                          return ValueListenableBuilder(
                            valueListenable: _controller.state,
                            builder: (_, state, __) => ValueListenableBuilder(
                              valueListenable: _tagsController,
                              builder: (_, selectedTags, __) {
                                final hasSelectedTag = selectedTags.isNotEmpty;
                                final searchRegionHeight = _kSearchBarHeight +
                                    (hasSelectedTag ? _kSelectedTagHeight : 0);

                                return Positioned(
                                  top: searchOnce
                                      ? state == SearchState.suggestions
                                          ? 0
                                          : -(_searchBarCurve.value *
                                              searchRegionHeight)
                                      : 0,
                                  left: 0,
                                  right: 0,
                                  child: child!,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: _buildSearchRegion(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchRegion(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          SizedBox(
            height: _kSearchBarHeight,
            child: _buildSearchBar(context),
          ),
          SelectedTagListWithData(
            controller: _tagsController,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
  ) {
    return Consumer(
      builder: (_, ref, __) {
        final autoFocusSearchBar = ref.watch(
          settingsProvider.select((value) => value.autoFocusSearchBar),
        );

        final parentRoute = ModalRoute.of(context);

        return SearchAppBar(
          onSubmitted: (value) => _controller.submit(value),
          trailingSearchButton: ValueListenableBuilder(
            valueListenable: _controller.didSearchOnce,
            builder: (_, searchOnce, __) {
              return !searchOnce
                  ? const SizedBox.shrink()
                  : ValueListenableBuilder(
                      valueListenable: _controller.state,
                      builder: (_, state, __) => state !=
                              SearchState.suggestions
                          ? AnimatedRotation(
                              duration: const Duration(milliseconds: 150),
                              turns: state == SearchState.options ? 0.13 : 0,
                              child: IconButton(
                                iconSize: 28,
                                onPressed: state != SearchState.options
                                    ? () {
                                        _controller
                                            .changeState(SearchState.options);
                                      }
                                    : () {
                                        _controller
                                            .changeState(SearchState.initial);
                                      },
                                icon: const Icon(Symbols.add),
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
            },
          ),
          innerSearchButton: ValueListenableBuilder(
            valueListenable: _controller.didSearchOnce,
            builder: (context, searchOnce, _) {
              return !searchOnce
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SearchButton2(
                        onTap: () {
                          _controller.search();
                          _postController?.refresh();
                        },
                      ),
                    );
            },
          ),
          focusNode: _controller.focus,
          autofocus: widget.initialQuery == null ? autoFocusSearchBar : false,
          controller: _controller.textController,
          leading: (parentRoute?.impliesAppBarDismissal ?? false)
              ? const SearchAppBarBackButton()
              : null,
        );
      },
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder(
      valueListenable: _controller.state,
      builder: (_, state, child) =>
          state == SearchState.suggestions ? child! : const SizedBox.shrink(),
      child: ValueListenableBuilder(
        valueListenable: _controller.didSearchOnce,
        builder: (_, searchOnce, __) => ColoredBox(
          color: colorScheme.surface,
          child: Container(
            padding: const EdgeInsets.only(
              top: _kSearchBarHeight,
            ),
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
                SelectedTagListWithData(
                  controller: _tagsController,
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _controller.textController,
                    builder: (context, query, child) {
                      final suggestionTags =
                          ref.watch(suggestionProvider(query.text));

                      return TagSuggestionItems(
                        config: ref.watchConfigAuth,
                        tags: suggestionTags,
                        currentQuery: query.text,
                        onItemTap: (tag) {
                          _controller.tapTag(tag.value);
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
          ),
        ),
      ),
    );
  }

  Widget _buildInitial(
    BuildContext context,
  ) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _controller.allowSearch,
        builder: (context, allow, child) => SearchButton(
          onSearch: () {
            _controller.search();
          },
          allowSearch: allow,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: _tagsController,
              builder: (_, value, __) {
                return SizedBox(
                  height: _kSearchBarHeight +
                      _kViewTopPadding +
                      (value.isNotEmpty ? _kSelectedTagHeight : 0),
                );
              },
            ),
            Expanded(
              child: SearchLandingView(
                onHistoryTap: (value) {
                  _controller.tapHistoryTag(value);
                },
                onTagTap: (value) {
                  _controller.tapTag(value);
                },
                onRawTagTap: (value) => _tagsController.addTag(
                  value,
                  isRaw: true,
                ),
                metatags: widget.metatags?.call(context, _controller),
                trending: widget.trending?.call(context, _controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultSearchResults(
    BuildContext context,
    PostGridController<T> controller,
  ) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: PostGrid<T>(
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
            ValueListenableBuilder(
              valueListenable: _tagsController,
              builder: (_, value, __) {
                return SliverSizedBox(
                  height: _kSearchBarHeight +
                      _kViewTopPadding +
                      (value.isNotEmpty ? _kSelectedTagHeight : 0),
                );
              },
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
                  ValueListenableBuilder(
                    valueListenable: _controller.tagString,
                    builder: (context, value, _) => ResultHeaderFromController(
                      controller: controller,
                      onRefresh: null,
                      hasCount: ref.watchConfigAuth.booruType.postCountMethod ==
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
    );
  }
}

class _SearchOptionsView extends ConsumerWidget {
  const _SearchOptionsView({
    required this.metatags,
  });

  final Widget? Function(BuildContext context, SearchPageController controller)?
      metatags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = InheritedSearchPageController.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder(
      valueListenable: controller.state,
      builder: (context, state, child) => state == SearchState.options
          ? ColoredBox(
              color: colorScheme.surface,
              child: SafeArea(
                bottom: false,
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
                    ValueListenableBuilder(
                      valueListenable: controller.tagsController,
                      builder: (_, value, __) {
                        return SizedBox(
                          height: _kSearchBarHeight +
                              _kViewTopPadding +
                              (value.isNotEmpty ? _kSelectedTagHeight : 0),
                        );
                      },
                    ),
                    Expanded(
                      child: child!,
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
      child: Scaffold(
        body: SearchLandingView(
          scrollController: ModalScrollController.of(
            context,
          ),
          onHistoryTap: (value) {
            controller.tapHistoryTag(
              value,
            );
          },
          onTagTap: (value) {
            controller.tapTag(value);
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
