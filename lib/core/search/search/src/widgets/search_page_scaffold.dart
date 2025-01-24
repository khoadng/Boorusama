// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
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
import 'sliver_search_app_bar.dart';

typedef IndexedSelectableSearchWidgetBuilder<T extends Post> = Widget Function(
  BuildContext context,
  int index,
  MultiSelectController<T> multiSelectController,
  AutoScrollController autoScrollController,
  PostGridController<T> controller,
  bool useHero,
);

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

  final Widget? Function(BuildContext)? metatags;
  final Widget? Function(BuildContext)? trending;

  @override
  ConsumerState<SearchPageScaffold<T>> createState() =>
      _SearchPageScaffoldState<T>();
}

class _SearchPageScaffoldState<T extends Post>
    extends ConsumerState<SearchPageScaffold<T>> {
  late final selectedTagController = SelectedTagController.fromBooruBuilder(
    builder: ref.read(currentBooruBuilderProvider),
    tagInfo: ref.read(tagInfoProvider),
  );
  final _scrollController = AutoScrollController();
  final _didSearchOnce = ValueNotifier(false);

  final CompositeSubscription _subscriptions = CompositeSubscription();
  late final SearchPageController searchController;

  @override
  void initState() {
    super.initState();

    searchController = SearchPageController(
      onSearch: () {
        ref
            .read(searchHistoryProvider.notifier)
            .addHistoryFromController(selectedTagController);
      },
      queryPattern: widget.queryPattern,
      selectedTagController: selectedTagController,
    );

    if (widget.initialQuery != null) {
      searchController.selectedTagString.value = widget.initialQuery!;
      selectedTagController.addTag(widget.initialQuery!);
      _didSearchOnce.value = true;
      searchController.skipToResultWithTag(widget.initialQuery!);
      ref
          .read(searchHistoryProvider.notifier)
          .addHistoryFromController(selectedTagController);
    }

    searchController.textEditingController
        .textAsStream()
        .pairwise()
        .listen((pair) {
      _onQueryChanged(pair.first, pair.last);
    }).addTo(_subscriptions);

    selectedTagController.addListener(_onSelectedTagChanged);
    searchController.selectedTagString.addListener(_onTagChanged);
  }

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

    final currentState = searchController.searchState.value;
    final nextState =
        current.isEmpty ? SearchState.initial : SearchState.suggestions;

    if (currentState != nextState) {
      searchController.searchState.value = nextState;
    }

    ref
        .read(suggestionsNotifierProvider(ref.readConfigAuth).notifier)
        .getSuggestions(current);
  }

  void _onSelectedTagChanged() {
    searchController.allowSearch.value =
        selectedTagController.rawTags.isNotEmpty;
  }

  @override
  void dispose() {
    selectedTagController.removeListener(_onSelectedTagChanged);
    searchController.selectedTagString.removeListener(_onTagChanged);

    _scrollController.dispose();
    _subscriptions.dispose();
    searchController.dispose();
    selectedTagController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: InheritedSearchPageController(
        controller: searchController,
        child: Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: searchController.searchState,
              builder: (_, state, child) => Offstage(
                offstage: state != SearchState.initial,
                child: child,
              ),
              child: ValueListenableBuilder(
                valueListenable: _didSearchOnce,
                builder: (context, searchOnce, child) {
                  //TODO: duplicated code
                  void search() {
                    _didSearchOnce.value = true;
                    searchController.search();
                  }

                  return searchOnce
                      ? PostScope(
                          fetcher: (page) => widget.fetcher(
                            page,
                            searchController.selectedTagController,
                          ),
                          builder: (context, controller) =>
                              _buildDefaultSearchResults(context, controller),
                        )
                      : _buildInitial(context, search);
                },
              ),
            ),
            ValueListenableBuilder(
              valueListenable: searchController.searchState,
              builder: (_, state, child) => state == SearchState.suggestions
                  ? child!
                  : const SizedBox.shrink(),
              child: ValueListenableBuilder(
                valueListenable: _didSearchOnce,
                builder: (_, searchOnce, __) => SuggestionView(
                  queryPattern: widget.queryPattern,
                  searchController: searchController,
                  previousRoute: !searchOnce
                      ? ModalRoute.of(context)?.settings
                      : const RouteSettings(name: '/search_result'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitial(
    BuildContext context,
    void Function() search,
  ) {
    final parentRoute = ModalRoute.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
        child: Consumer(
          builder: (_, ref, __) {
            final autoFocusSearchBar = ref.watch(
              settingsProvider.select((value) => value.autoFocusSearchBar),
            );

            return SearchAppBar(
              focusNode: searchController.focus,
              autofocus: autoFocusSearchBar,
              controller: searchController.textEditingController,
              leading: (parentRoute?.impliesAppBarDismissal ?? false)
                  ? const SearchAppBarBackButton()
                  : null,
            );
          },
        ),
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: searchController.allowSearch,
        builder: (context, allow, child) => SearchButton(
          onSearch: search,
          allowSearch: allow,
        ),
      ),
      body: Column(
        children: [
          SelectedTagListWithData(
            controller: selectedTagController,
          ),
          Expanded(
            child: SearchLandingView(
              onHistoryTap: (value) {
                searchController.tapHistoryTag(value);
              },
              onTagTap: (value) {
                searchController.tapTag(value);
              },
              onRawTagTap: (value) => selectedTagController.addTag(
                value,
                isRaw: true,
              ),
              metatags: widget.metatags?.call(context),
              trending: widget.trending?.call(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSearchResults(
    BuildContext context,
    PostGridController<T> controller,
  ) {
    return PostGrid<T>(
      scrollController: _scrollController,
      controller: controller,
      itemBuilder: widget.itemBuilder != null
          ? (context, index, multiSelectController, scrollController, useHero) {
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
        SliverSearchAppBar(
          search: () {
            _didSearchOnce.value = true;
            searchController.search();
            controller.refresh();
          },
          searchController: searchController,
          selectedTagController: selectedTagController,
          metatags: widget.metatags?.call(context),
        ),
        SliverToBoxAdapter(
          child: SelectedTagListWithData(
            controller: selectedTagController,
          ),
        ),
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
                valueListenable: searchController.selectedTagString,
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
    ref.read(analyticsProvider).logScreenView('/search_result');
  }

  @override
  Widget build(BuildContext context) {
    return const SliverSizedBox.shrink();
  }
}

class SuggestionView extends ConsumerStatefulWidget {
  const SuggestionView({
    required this.searchController,
    required this.previousRoute,
    super.key,
    this.queryPattern,
  });

  final Map<RegExp, TextStyle>? queryPattern;
  final SearchPageController searchController;
  // dirty hack to get the previous route since suggestions are not a route
  final RouteSettings? previousRoute;

  @override
  ConsumerState<SuggestionView> createState() => _SuggestionViewState();
}

class _SuggestionViewState extends ConsumerState<SuggestionView> {
  final focus = FocusNode();
  late final textController = RichTextController(
    text: widget.searchController.textEditingController.text,
    patternMatchMap: widget.queryPattern ??
        {
          RegExp(''): const TextStyle(color: Colors.white),
        },
    onMatch: (match) {},
  );

  @override
  void initState() {
    super.initState();
    focus.requestFocus();
    textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    textController
      ..removeListener(_onTextChanged)
      ..dispose();
    focus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.searchController.updateQuery(textController.text);
  }

  @override
  Widget build(BuildContext context) {
    final selectedTagController = widget.searchController.selectedTagController;
    final searchController = widget.searchController;
    final parentRoute = ModalRoute.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
        child: SearchAppBar(
          focusNode: focus,
          controller: textController,
          onSubmitted: (value) => widget.searchController.submit(value),
          leading: (parentRoute?.impliesAppBarDismissal ?? false)
              ? const SearchAppBarBackButton()
              : null,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SuggestionViewAnalyticsAnchor(
              previousRoute: widget.previousRoute,
              analytics: ref.watch(analyticsProvider),
            ),
            SelectedTagListWithData(
              controller: selectedTagController,
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: textController,
                builder: (context, query, child) {
                  final suggestionTags =
                      ref.watch(suggestionProvider(query.text));

                  return TagSuggestionItems(
                    config: ref.watchConfigAuth,
                    tags: suggestionTags,
                    currentQuery: query.text,
                    onItemTap: (tag) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      searchController.tapTag(tag.value);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestionViewAnalyticsAnchor extends ConsumerStatefulWidget {
  const SuggestionViewAnalyticsAnchor({
    required this.previousRoute,
    required this.analytics,
    super.key,
  });

  final RouteSettings? previousRoute;
  final AnalyticsInterface analytics;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SuggestionViewAnalyticsAnchoreState();
}

class _SuggestionViewAnalyticsAnchoreState
    extends ConsumerState<SuggestionViewAnalyticsAnchor> {
  @override
  void initState() {
    super.initState();
    widget.analytics.logScreenView('/search_suggestions');
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
