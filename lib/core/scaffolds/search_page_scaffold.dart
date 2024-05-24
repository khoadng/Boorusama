// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/pages/search/search_app_bar.dart';
import 'package:boorusama/core/pages/search/search_button.dart';
import 'package:boorusama/core/pages/search/search_landing_view.dart';
import 'package:boorusama/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';
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

  final PostsOrErrorCore<T> Function(int page, List<String> tags) fetcher;

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
    TextEditingValue value,
  )? resultBuilder;

  @override
  ConsumerState<SearchPageScaffold<T>> createState() =>
      _SearchPageScaffoldState<T>();
}

class _SearchPageScaffoldState<T extends Post>
    extends ConsumerState<SearchPageScaffold<T>> {
  var selectedTagString = ValueNotifier('');
  late final selectedTagController = SelectedTagController(
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

  late final searchController = SearchPageController(
    textEditingController: textController,
    searchHistory: ref.read(searchHistoryProvider.notifier),
    selectedTagController: selectedTagController,
    suggestions: ref.read(suggestionsProvider(ref.readConfig).notifier),
    focus: focus,
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

  bool allowSearch(List<TagSearchItem> tags) => tags.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: ValueListenableBuilder(
        valueListenable: textController,
        builder: (context, value, child) => Stack(
          children: [
            Offstage(
              offstage: value.text.isNotEmpty,
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
                      ? widget.resultBuilder != null
                          ? widget.resultBuilder!(
                              _didSearchOnce,
                              selectedTagString,
                              _scrollController,
                              selectedTagController,
                              searchController,
                              value,
                            )
                          : _buildDefaultSearchResults(
                              selectedTagController,
                              searchController,
                              focus,
                              textController,
                              value,
                            )
                      : _buildInitial(context, search);
                },
              ),
            ),
            value.text.isNotEmpty
                ? Scaffold(
                    appBar: PreferredSize(
                      preferredSize:
                          const Size.fromHeight(kToolbarHeight * 1.2),
                      child: SearchAppBar(
                        focusNode: focus,
                        queryEditingController: textController,
                        onSubmitted: (value) => searchController.submit(value),
                        leading: (!context.canPop()
                            ? null
                            : const SearchAppBarBackButton()),
                      ),
                    ),
                    body: DefaultSearchSuggestionView(
                      textEditingController: textController,
                      searchController: searchController,
                      selectedTagController: selectedTagController,
                    ),
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
          onSubmitted: (value) {
            searchController.submit(value);
            textController.clear();
          },
          leading: (!context.canPop() ? null : const SearchAppBarBackButton()),
        ),
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: selectedTagController,
        builder: (context, tags, child) => SearchButton(
          onSearch: search,
          allowSearch: allowSearch(tags),
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
    SelectedTagController selectedTagController,
    SearchPageController searchController,
    FocusNode focus,
    RichTextController textController,
    TextEditingValue value,
  ) {
    return PostScope(
      fetcher: (page) =>
          widget.fetcher.call(page, selectedTagController.rawTags),
      builder: (context, controller, errors) {
        void search() {
          searchController.search();
          selectedTagString.value = selectedTagController.rawTagsString;
          controller.refresh();
        }

        final slivers = [
          SliverAppBar(
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            toolbarHeight: kToolbarHeight * 1.2,
            backgroundColor: context.theme.scaffoldBackgroundColor,
            title: SearchAppBar(
              focusNode: focus,
              autofocus: false,
              queryEditingController: textController,
              onSubmitted: (value) {
                searchController.submit(value);
                textController.clear();
              },
              leading:
                  (!context.canPop() ? null : const SearchAppBarBackButton()),
              innerSearchButton: value.text.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SearchButton2(
                        onTap: search,
                      ),
                    )
                  : null,
              trailingSearchButton: IconButton(
                onPressed: () => showBarModalBottomSheet(
                  context: context,
                  builder: (context) => Scaffold(
                    body: SafeArea(
                      child: SearchLandingView(
                        scrollController: ModalScrollController.of(context),
                        onHistoryCleared: () => ref
                            .read(searchHistoryProvider.notifier)
                            .clearHistories(),
                        onHistoryRemoved: (value) => ref
                            .read(searchHistoryProvider.notifier)
                            .removeHistory(value.query),
                        onHistoryTap: (value) {
                          searchController.tapHistoryTag(value);
                          context.pop();
                        },
                        onTagTap: (value) {
                          searchController.tapTag(value);
                          context.pop();
                        },
                      ),
                    ),
                  ),
                ),
                icon: const Icon(Symbols.sort),
              ),
            ),
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
        ];

        return InfinitePostListScaffold(
          errors: errors,
          controller: controller,
          sliverHeaderBuilder: (context) => slivers,
        );
      },
    );
  }
}
