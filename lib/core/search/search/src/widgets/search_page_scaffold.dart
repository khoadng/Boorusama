// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../boorus/booru/booru.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../posts/count/widgets.dart';
import '../../../../posts/listing/providers.dart';
import '../../../../posts/listing/widgets.dart';
import '../../../../posts/post/post.dart';
import '../../../../settings/providers.dart';
import '../../../../tags/configs/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../histories/providers.dart';
import '../../../selected_tags/selected_tag_controller.dart';
import '../../../suggestions/suggestions_notifier.dart';
import '../../../suggestions/tag_suggestion_items.dart';
import '../views/search_landing_view.dart';
import 'search_app_bar.dart';
import 'search_button.dart';
import 'search_controller.dart';
import 'search_mixin.dart';
import 'selected_tag_list_with_data.dart';
import 'sliver_search_app_bar.dart';

typedef IndexedSelectableSearchWidgetBuilder<T extends Post> = Widget Function(
  BuildContext context,
  int index,
  MultiSelectController<T> multiSelectController,
  AutoScrollController autoScrollController,
  PostGridController<T> controller,
);

class SearchPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const SearchPageScaffold({
    required this.fetcher,
    super.key,
    this.initialQuery,
    this.noticeBuilder,
    this.queryPattern,
    this.metatagsBuilder,
    this.trendingBuilder,
    this.extraHeaders,
    this.itemBuilder,
  });

  final String? initialQuery;

  final Widget Function(BuildContext context)? noticeBuilder;

  final List<Widget> Function(
    ValueNotifier<String> selectedTagString,
    SelectedTagController selectedTagController,
    SearchPageController searchController,
    PostGridController<T> postController,
  )? extraHeaders;

  final PostsOrErrorCore<T> Function(
    int page,
    SelectedTagController selectedTagController,
  ) fetcher;

  final Map<RegExp, TextStyle>? queryPattern;

  final IndexedSelectableSearchWidgetBuilder<T>? itemBuilder;

  final Widget Function(BuildContext context, SearchPageController controller)?
      metatagsBuilder;
  final Widget Function(BuildContext context, SearchPageController controller)?
      trendingBuilder;

  @override
  ConsumerState<SearchPageScaffold<T>> createState() =>
      _SearchPageScaffoldState<T>();
}

class _SearchPageScaffoldState<T extends Post>
    extends ConsumerState<SearchPageScaffold<T>> {
  var selectedTagString = ValueNotifier('');
  late final selectedTagController = SelectedTagController.fromBooruBuilder(
    builder: ref.read(currentBooruBuilderProvider),
    tagInfo: ref.read(tagInfoProvider),
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
    suggestions:
        ref.read(suggestionsNotifierProvider(ref.readConfigAuth).notifier),
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
                            searchController.selectedTagController,
                          ),
                          builder: (context, controller) =>
                              _buildDefaultSearchResults(controller),
                        )
                      : _buildInitial(context, search);
                },
              ),
            ),
            if (state == SearchState.suggestions)
              SuggestionView(
                queryPattern: widget.queryPattern,
                searchController: searchController,
              )
            else
              const SizedBox.shrink(),
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
        child: SearchAppBar(
          focusNode: focus,
          autofocus: ref.watch(settingsProvider).autoFocusSearchBar,
          controller: textController,
          leading: (parentRoute?.impliesAppBarDismissal ?? false)
              ? const SearchAppBarBackButton()
              : null,
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
              onHistoryRemoved: (value) =>
                  ref.read(searchHistoryProvider.notifier).removeHistory(value),
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
    PostGridController<T> controller,
  ) {
    return PostGrid<T>(
      scrollController: _scrollController,
      controller: controller,
      itemBuilder: widget.itemBuilder != null
          ? (context, index, multiSelectController, scrollController) {
              return widget.itemBuilder!(
                context,
                index,
                multiSelectController,
                _scrollController,
                controller,
              );
            }
          : null,
      sliverHeaders: [
        SliverSearchAppBar(
          search: () {
            _didSearchOnce.value = true;
            searchController.search();
            controller.refresh();
            selectedTagString.value = selectedTagController.rawTagsString;
          },
          searchController: searchController,
          selectedTagController: selectedTagController,
          metatagsBuilder: widget.metatagsBuilder != null
              ? (context, _) => widget.metatagsBuilder!(
                    context,
                    searchController,
                  )
              : null,
        ),
        SliverToBoxAdapter(
          child: SelectedTagListWithData(
            controller: selectedTagController,
          ),
        ),
        if (widget.extraHeaders != null)
          ...widget.extraHeaders!(
            selectedTagString,
            selectedTagController,
            searchController,
            controller,
          ),
        SliverToBoxAdapter(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder(
                valueListenable: selectedTagString,
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

class SuggestionView extends ConsumerStatefulWidget {
  const SuggestionView({
    required this.searchController,
    super.key,
    this.queryPattern,
  });

  final Map<RegExp, TextStyle>? queryPattern;
  final SearchPageController searchController;

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
