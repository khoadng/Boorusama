// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/search_histories/search_histories.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/router.dart';

class SearchPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const SearchPageScaffold({
    super.key,
    this.initialQuery,
    required this.fetcher,
    this.noticeBuilder,
    this.queryPattern,
    this.metatagsBuilder,
    this.trendingBuilder,
    this.resultBuilder,
  });

  final String? initialQuery;

  final Widget Function(BuildContext context)? noticeBuilder;

  final PostsOrErrorCore<T> Function(int page, String tags) fetcher;

  final Map<RegExp, TextStyle>? queryPattern;

  final Widget Function(BuildContext context, SearchPageController controller)?
      metatagsBuilder;
  final Widget Function(BuildContext context, SearchPageController controller)?
      trendingBuilder;

  final Widget Function(
    ValueNotifier<bool> didSearchOnce,
    ValueNotifier<String> selectedTagString,
    AutoScrollController scrollController,
    SelectedTagController selectedTagController,
    SearchPageController searchController,
    BooruError? errors,
    PostGridController<T> postController,
  )? resultBuilder;

  @override
  ConsumerState<SearchPageScaffold<T>> createState() =>
      _SearchPageScaffoldState<T>();
}

class _SearchPageScaffoldState<T extends Post>
    extends ConsumerState<SearchPageScaffold<T>> {
  var selectedTagString = ValueNotifier('');
  late final selectedTagController = SelectedTagController.fromBooruBuilder(
    builder: ref.readBooruBuilder(ref.readConfig),
  );
  final _scrollController = AutoScrollController();
  final _didSearchOnce = ValueNotifier(false);
  late final textController = RichTextController(
    patternMatchMap: widget.queryPattern ??
        {
          RegExp(''): const TextStyle(color: Colors.white),
        },
    onMatch: (match) {},
  );
  final focus = FocusNode();

  final searchState = ValueNotifier(SearchState.initial);
  late final allowSearch = ValueNotifier(false);

  late final searchController = SearchPageController(
    textEditingController: textController,
    searchHistory: ref.read(searchHistoryProvider.notifier),
    selectedTagController: selectedTagController,
    suggestions: ref.read(suggestionsProvider(ref.readConfig).notifier),
    focus: focus,
    searchState: searchState,
    allowSearch: allowSearch,
  );

  @override
  void initState() {
    super.initState();

    if (widget.initialQuery != null) {
      selectedTagString.value = widget.initialQuery!;
      selectedTagController.addTag(widget.initialQuery!);
      _didSearchOnce.value = true;
      searchController.skipToResultWithTag(widget.initialQuery!);
    }

    selectedTagString.addListener(_onTagChanged);
  }

  void _onTagChanged() {
    // check if scroll controller is attached
    if (_scrollController.hasClients) {
      // scroll to top when tag is added
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    selectedTagString.dispose();
    textController.dispose();
    searchController.dispose();

    focus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: ValueListenableBuilder(
        valueListenable: searchController.searchState,
        builder: (_, state, __) => Stack(
          children: [
            Offstage(
              offstage: state != SearchState.initial,
              child: ValueListenableBuilder(
                valueListenable: _didSearchOnce,
                builder: (context, searchOnce, child) {
                  //TODO: duplicated code
                  void search() {
                    _didSearchOnce.value = true;
                    searchController.search();
                    selectedTagString.value =
                        selectedTagController.rawTagsString;
                  }

                  return searchOnce
                      ? PostScope(
                          fetcher: (page) => widget.fetcher(
                            page,
                            searchController.getCurrentRawTags(),
                          ),
                          builder: (context, controller, errors) =>
                              widget.resultBuilder != null
                                  ? widget.resultBuilder!(
                                      _didSearchOnce,
                                      selectedTagString,
                                      _scrollController,
                                      selectedTagController,
                                      searchController,
                                      errors,
                                      controller,
                                    )
                                  : _buildDefaultSearchResults(
                                      errors,
                                      controller,
                                    ),
                        )
                      : _buildInitial(context, search);
                },
              ),
            ),
            state == SearchState.suggestions
                ? SuggestionView(
                    queryPattern: widget.queryPattern,
                    searchController: searchController,
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildInitial(
    BuildContext context,
    void Function() search,
  ) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
        child: SearchAppBar(
          focusNode: focus,
          autofocus: ref.watch(settingsProvider).autoFocusSearchBar,
          queryEditingController: textController,
          leading: (!context.canPop() ? null : const SearchAppBarBackButton()),
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
              onHistoryCleared: () =>
                  ref.read(searchHistoryProvider.notifier).clearHistories(),
              onHistoryRemoved: (value) => ref
                  .read(searchHistoryProvider.notifier)
                  .removeHistory(value.query),
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
              metatagsBuilder: widget.metatagsBuilder != null
                  ? (context) => widget.metatagsBuilder!(
                        context,
                        searchController,
                      )
                  : null,
              trendingBuilder: widget.trendingBuilder != null
                  ? (context) => widget.trendingBuilder!(
                        context,
                        searchController,
                      )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSearchResults(
    BooruError? errors,
    PostGridController controller,
  ) {
    return InfinitePostListScaffold(
      errors: errors,
      controller: controller,
      sliverHeaderBuilder: (context) => [
        SliverSearchAppBar(
          search: () {
            searchController.search();
            selectedTagString.value = selectedTagController.rawTagsString;
            controller.refresh();
          },
          searchController: searchController,
          selectedTagController: selectedTagController,
        ),
        SliverToBoxAdapter(
            child: SelectedTagListWithData(
          controller: selectedTagController,
        )),
        SliverToBoxAdapter(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...[
                ValueListenableBuilder(
                  valueListenable: selectedTagString,
                  builder: (context, value, _) => ResultHeaderWithProvider(
                    selectedTags: value.split(' '),
                    onRefresh: null,
                  ),
                ),
                const Spacer(),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

class SuggestionView extends StatefulWidget {
  const SuggestionView({
    super.key,
    required this.searchController,
    this.queryPattern,
  });

  final Map<RegExp, TextStyle>? queryPattern;
  final SearchPageController searchController;

  @override
  State<SuggestionView> createState() => _SuggestionViewState();
}

class _SuggestionViewState extends State<SuggestionView> {
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
    textController.removeListener(_onTextChanged);
    textController.dispose();
    focus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.searchController.updateQuery(textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
        child: SearchAppBar(
          focusNode: focus,
          queryEditingController: textController,
          onSubmitted: (value) => widget.searchController.submit(value),
          leading: (!context.canPop() ? null : const SearchAppBarBackButton()),
        ),
      ),
      body: DefaultSearchSuggestionView(
        textEditingController: textController,
        searchController: widget.searchController,
        selectedTagController: widget.searchController.selectedTagController,
      ),
    );
  }
}
