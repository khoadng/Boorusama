// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/pages/search/search_app_bar.dart';
import 'package:boorusama/core/pages/search/search_button.dart';
import 'package:boorusama/core/pages/search/search_landing_view.dart';
import 'package:boorusama/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/router.dart';

class SearchPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const SearchPageScaffold({
    super.key,
    this.initialQuery,
    required this.fetcher,
    this.gridBuilder,
    this.noticeBuilder,
    required this.searchBarLeading,
    required this.searchTrailing,
  });

  final String? initialQuery;

  final Widget Function(BuildContext context)? noticeBuilder;

  final PostsOrErrorCore<T> Function(int page, List<String> tags) fetcher;

  final Widget Function(
    BuildContext context,
    PostGridController<T> controller,
    List<Widget> slivers,
  )? gridBuilder;

  final Widget? searchBarLeading;
  final Widget? searchTrailing;

  @override
  ConsumerState<SearchPageScaffold<T>> createState() =>
      _SearchPageScaffoldState<T>();
}

class _SearchPageScaffoldState<T extends Post>
    extends ConsumerState<SearchPageScaffold<T>> {
  var selectedTagString = ValueNotifier('');

  @override
  void initState() {
    super.initState();

    if (widget.initialQuery != null) {
      selectedTagString.value = widget.initialQuery!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SearchScope(
      initialQuery: widget.initialQuery,
      builder: (state, focus, textController, selectedTagController,
              searchController, allowSearch) =>
          ValueListenableBuilder(
        valueListenable: textController,
        builder: (context, value, child) => Stack(
          children: [
            Offstage(
                offstage: value.text.isNotEmpty,
                child: PostScope(
                  fetcher: (page) =>
                      widget.fetcher.call(page, selectedTagController.rawTags),
                  builder: (context, controller, errors) {
                    void search() {
                      searchController.search();
                      selectedTagString.value =
                          selectedTagController.rawTagsString;
                      controller.refresh();
                    }

                    final slivers = [
                      const SliverAppAnnouncementBanner(),
                      SliverToBoxAdapter(
                        child: SearchAppBar(
                          focusNode: focus,
                          queryEditingController: textController,
                          onSubmitted: (value) =>
                              searchController.submit(value),
                          leading: widget.searchBarLeading ??
                              (!context.canPop()
                                  ? null
                                  : const SearchAppBarBackButton()),
                          innerSearchButton: value.text.isEmpty
                              ? widget.searchTrailing != null
                                  ? Row(
                                      children: [
                                        SearchButton(
                                          onTap: search,
                                        ),
                                        widget.searchTrailing!,
                                        const SizedBox(width: 8),
                                      ],
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: SearchButton(
                                        onTap: search,
                                      ),
                                    )
                              : null,
                          trailingSearchButton: IconButton(
                            onPressed: () => showBarModalBottomSheet(
                              context: context,
                              builder: (context) => Scaffold(
                                body: SafeArea(
                                  child: CustomScrollView(
                                    slivers: [
                                      SliverToBoxAdapter(
                                        child: SearchLandingView(
                                          onHistoryCleared: () => ref
                                              .read(searchHistoryProvider
                                                  .notifier)
                                              .clearHistories(),
                                          onHistoryRemoved: (value) => ref
                                              .read(searchHistoryProvider
                                                  .notifier)
                                              .removeHistory(value.query),
                                          onHistoryTap: (value) {
                                            searchController
                                                .tapHistoryTag(value);
                                          },
                                          onTagTap: (value) {
                                            searchController.tapTag(value);
                                            context.pop();
                                          },
                                        ),
                                      ),
                                    ],
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
                                builder: (context, value, _) =>
                                    ResultHeaderWithProvider(
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

                    return widget.gridBuilder != null
                        ? widget.gridBuilder!(context, controller, slivers)
                        : InfinitePostListScaffold(
                            errors: errors,
                            controller: controller,
                            sliverHeaderBuilder: (context) => slivers,
                          );
                  },
                )),
            Offstage(
              offstage: value.text.isEmpty,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
                  child: SearchAppBar(
                    focusNode: focus,
                    queryEditingController: textController,
                    onSubmitted: (value) => searchController.submit(value),
                    leading: widget.searchBarLeading ??
                        (!context.canPop()
                            ? null
                            : const SearchAppBarBackButton()),
                  ),
                ),
                body: DefaultSearchSuggestionView(
                  textEditingController: textController,
                  searchController: searchController,
                  selectedTagController: selectedTagController,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
