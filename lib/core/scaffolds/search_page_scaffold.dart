// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/pages/search/search_app_bar.dart';
import 'package:boorusama/core/pages/search/search_app_bar_result_view.dart';
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
  });

  final String? initialQuery;

  final Widget Function(BuildContext context)? noticeBuilder;

  final PostsOrErrorCore<T> Function(int page, List<String> tags) fetcher;

  final Widget Function(
    BuildContext context,
    PostGridController<T> controller,
    List<Widget> slivers,
  )? gridBuilder;

  @override
  ConsumerState<SearchPageScaffold<T>> createState() =>
      _SearchPageScaffoldState<T>();
}

class _SearchPageScaffoldState<T extends Post>
    extends ConsumerState<SearchPageScaffold<T>> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final booruBuilder = ref.read(booruBuilderProvider);
      final postCountFetcher = booruBuilder?.postCountFetcher;

      if (postCountFetcher != null && widget.initialQuery != null) {
        ref
            .read(postCountStateProvider(ref.readConfig).notifier)
            .getPostCount([widget.initialQuery!]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final booruBuilder = ref.watch(booruBuilderProvider);
    final postCountFetcher = booruBuilder?.postCountFetcher;

    return CustomContextMenuOverlay(
      child: SearchScope(
        initialQuery: widget.initialQuery,
        builder: (state, focus, controller, selectedTagController,
                searchController, allowSearch) =>
            switch (state) {
          DisplayState.options => Scaffold(
              floatingActionButton: SearchButton(
                allowSearch: allowSearch,
                onSearch: () {
                  if (postCountFetcher != null) {
                    ref
                        .read(postCountStateProvider(ref.readConfig).notifier)
                        .getPostCount(selectedTagController.rawTags);
                  }

                  searchController.search();
                },
              ),
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
                child: SearchAppBar(
                  focusNode: focus,
                  queryEditingController: controller,
                  onSubmitted: (value) => searchController.submit(value),
                  onBack: () => state != DisplayState.options
                      ? searchController.resetToOptions()
                      : context.pop(),
                ),
              ),
              body: SafeArea(
                child: CustomScrollView(slivers: [
                  SliverPinnedHeader(
                    child: SelectedTagListWithData(
                      controller: selectedTagController,
                      onDeleted: (value) => searchController.resetToOptions(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SearchLandingView(
                      noticeBuilder: widget.noticeBuilder,
                      onHistoryCleared: () => ref
                          .read(searchHistoryProvider.notifier)
                          .clearHistories(),
                      onHistoryRemoved: (value) => ref
                          .read(searchHistoryProvider.notifier)
                          .removeHistory(value.query),
                      onHistoryTap: (value) =>
                          searchController.tapHistoryTag(value),
                      onTagTap: (value) => searchController.tapTag(value),
                    ),
                  ),
                ]),
              ),
            ),
          DisplayState.suggestion => Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
                child: SearchAppBar(
                  focusNode: focus,
                  queryEditingController: controller,
                  onSubmitted: (value) => searchController.submit(value),
                  onBack: () => state != DisplayState.options
                      ? searchController.resetToOptions()
                      : context.pop(),
                ),
              ),
              body: DefaultSearchSuggestionView(
                selectedTagController: selectedTagController,
                textEditingController: controller,
                searchController: searchController,
              ),
            ),
          DisplayState.result => PostScope(
              fetcher: (page) =>
                  widget.fetcher.call(page, selectedTagController.rawTags),
              builder: (context, controller, errors) {
                final slivers = [
                  SearchAppBarResultView(
                    onTap: () => searchController.goToSuggestions(),
                    onBack: () => searchController.resetToOptions(),
                  ),
                  SliverToBoxAdapter(
                      child: SelectedTagListWithData(
                    controller: selectedTagController,
                    onDeleted: (value) => searchController.resetToOptions(),
                  )),
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (postCountFetcher != null) ...[
                          ResultHeaderWithProvider(
                              selectedTags: selectedTagController.rawTags),
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
            ),
        },
      ),
    );
  }
}
