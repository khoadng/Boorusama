// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/pages/widgets/search/result_view.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/search/trending_section.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';

class DanbooruSearchPage extends ConsumerWidget {
  const DanbooruSearchPage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchPageScaffold(
      // just return empty, we dont need to fetch anything
      fetcher: (page, tags) => TaskEither.right(<Post>[]),
      initialQuery: initialQuery,
      queryPattern: {
        RegExp('(${ref.watch(metatagsProvider).map((e) => e.name).join('|')})+:'):
            TextStyle(
          fontWeight: FontWeight.w800,
          color: context.colorScheme.primary,
        ),
      },
      trendingBuilder: (context, controller) => TrendingSection(
        onTagTap: (value) {
          controller.tapTag(value);
        },
      ),
      metatagsBuilder: (context, controller) =>
          _buildMetatagSection(ref, controller),
      resultBuilder: (
        didSearchOnce,
        selectedTagString,
        scrollController,
        selectedTagController,
        searchController,
      ) =>
          _buildDefaultSearchResults(
        ref,
        didSearchOnce,
        selectedTagString,
        scrollController,
        selectedTagController,
        searchController,
      ),
    );
  }

  Widget _buildMetatagSection(
    WidgetRef ref,
    SearchPageController controller, {
    bool popOnSelect = false,
  }) {
    return DanbooruMetatagsSection(
      onOptionTap: (value) {
        controller.tapRawMetaTag(value);
        controller.focus.requestFocus();
        controller.textEditingController.setTextAndCollapseSelection('$value:');

        //TODO: need to handle case where the options page is a dialog
        if (popOnSelect) {
          ref.context.pop();
        }
      },
    );
  }

  Widget _buildDefaultSearchResults(
    WidgetRef ref,
    ValueNotifier<bool> didSearchOnce,
    ValueNotifier<String> selectedTagString,
    AutoScrollController scrollController,
    SelectedTagController selectedTagController,
    SearchPageController searchController,
  ) {
    final context = ref.context;

    return ResultView(
      scrollController: scrollController,
      selectedTagString: selectedTagString,
      searchController: searchController,
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
          didSearchOnce.value = true;
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
              autofocus: false,
              queryEditingController: searchController.textEditingController,
              leading:
                  (!context.canPop() ? null : const SearchAppBarBackButton()),
              innerSearchButton: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SearchButton2(
                  onTap: search,
                ),
              ),
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
                        metatagsBuilder: (context) => _buildMetatagSection(
                          ref,
                          searchController,
                          popOnSelect: true,
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
