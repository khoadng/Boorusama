// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/pages/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/core/pages/search/search_app_bar.dart';
import 'package:boorusama/core/pages/search/search_button.dart';
import 'package:boorusama/core/pages/search/search_landing_view.dart';
import 'package:boorusama/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'widgets/search/result_view.dart';
import 'widgets/search/trending_section.dart';

class DanbooruSearchPage extends ConsumerStatefulWidget {
  const DanbooruSearchPage({
    super.key,
    this.initialQuery,
    this.searchBarLeading,
    this.searchTrailing,
  });

  final String? initialQuery;
  final Widget? searchBarLeading;
  final Widget? searchTrailing;

  @override
  ConsumerState<DanbooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<DanbooruSearchPage> {
  late final metaTagRegex =
      RegExp('(${ref.watch(metatagsProvider).map((e) => e.name).join('|')})+:');

  var selectedTagString = ValueNotifier('');
  late final _selectedTagController = SelectedTagController(
    tagInfo: ref.read(tagInfoProvider),
  );
  final _scrollController = AutoScrollController();
  final _didSearchOnce = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    if (widget.initialQuery != null) {
      selectedTagString.value = widget.initialQuery!;
      _selectedTagController.addTag(widget.initialQuery!);
      _didSearchOnce.value = true;
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
  }

  @override
  Widget build(BuildContext context) {
    return SearchScope(
      selectedTagController: _selectedTagController,
      initialQuery: widget.initialQuery,
      pattern: {
        metaTagRegex: TextStyle(
          fontWeight: FontWeight.w800,
          color: context.colorScheme.primary,
        ),
      },
      builder: (focus, controller, selectedTagController, searchController,
              allowSearch) =>
          ValueListenableBuilder(
        valueListenable: controller,
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
                      ? _buildSearchResults(
                          selectedTagController,
                          searchController,
                          focus,
                          controller,
                          value,
                        )
                      : Scaffold(
                          appBar: PreferredSize(
                            preferredSize:
                                const Size.fromHeight(kToolbarHeight * 1.2),
                            child: SearchAppBar(
                              focusNode: focus,
                              autofocus: ref
                                  .watch(settingsProvider)
                                  .autoFocusSearchBar,
                              queryEditingController: controller,
                              onSubmitted: (value) {
                                searchController.submit(value);
                                controller.clear();
                              },
                              leading: widget.searchBarLeading ??
                                  (!context.canPop()
                                      ? null
                                      : const SearchAppBarBackButton()),
                            ),
                          ),
                          floatingActionButton: SearchButton(
                            onSearch: search,
                            allowSearch: allowSearch,
                          ),
                          body: Column(
                            children: [
                              SelectedTagListWithData(
                                controller: selectedTagController,
                              ),
                              Expanded(
                                child: SearchLandingView(
                                  onHistoryCleared: () => ref
                                      .read(searchHistoryProvider.notifier)
                                      .clearHistories(),
                                  onHistoryRemoved: (value) => ref
                                      .read(searchHistoryProvider.notifier)
                                      .removeHistory(value.query),
                                  onHistoryTap: (value) {
                                    searchController.tapHistoryTag(value);
                                  },
                                  onTagTap: (value) {
                                    searchController.tapTag(value);
                                  },
                                  trendingBuilder: (context) => TrendingSection(
                                    onTagTap: (value) {
                                      searchController.tapTag(value);
                                    },
                                  ),
                                  metatagsBuilder: (context) =>
                                      DanbooruMetatagsSection(
                                    onOptionTap: (value) {
                                      searchController.tapRawMetaTag(value);
                                      focus.requestFocus();
                                      _onTextChanged(controller, '$value:');
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
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
                        queryEditingController: controller,
                        onSubmitted: (value) => searchController.submit(value),
                        leading: widget.searchBarLeading ??
                            (!context.canPop()
                                ? null
                                : const SearchAppBarBackButton()),
                      ),
                    ),
                    body: DefaultSearchSuggestionView(
                      textEditingController: controller,
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

  Widget _buildSearchResults(
    SelectedTagController selectedTagController,
    SearchPageController searchController,
    FocusNode focus,
    RichTextController controller,
    TextEditingValue value,
  ) {
    return ResultView(
      scrollController: _scrollController,
      selectedTagString: selectedTagString,
      selectedTagController: selectedTagController,
      onRelatedTagAdded: (tag, postController) {
        selectedTagController.addTag(tag.tag);
        postController.refresh();
        selectedTagString.value = selectedTagController.rawTagsString;
        searchController.search();
      },
      onRelatedTagNegated: (tag, postController) {
        selectedTagController.negateTag(tag.tag);
        postController.refresh();
        selectedTagString.value = selectedTagController.rawTagsString;
        searchController.search();
      },
      headerBuilder: (postController) {
        void search() {
          _didSearchOnce.value = true;
          searchController.search();
          postController.refresh();
          selectedTagString.value = selectedTagController.rawTagsString;
        }

        return [
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
              queryEditingController: controller,
              onSubmitted: (value) {
                searchController.submit(value);
                controller.clear();
              },
              leading: widget.searchBarLeading ??
                  (!context.canPop() ? null : const SearchAppBarBackButton()),
              innerSearchButton: value.text.isEmpty
                  ? widget.searchTrailing != null
                      ? Row(
                          children: [
                            SearchButton2(
                              onTap: search,
                            ),
                            widget.searchTrailing!,
                            const SizedBox(width: 8),
                          ],
                        )
                      : Padding(
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
                        metatagsBuilder: (context) => DanbooruMetatagsSection(
                          onOptionTap: (value) {
                            searchController.tapRawMetaTag(value);
                            focus.requestFocus();
                            _onTextChanged(controller, '$value:');
                            context.pop();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                icon: const Icon(Symbols.sort),
              ),
            ),
          ),
        ];
      },
    );
  }
}

void _onTextChanged(
  TextEditingController controller,
  String text,
) {
  controller
    ..text = text
    ..selection = TextSelection.collapsed(offset: controller.text.length);
}
