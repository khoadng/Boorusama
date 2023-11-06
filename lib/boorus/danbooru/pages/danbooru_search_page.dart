// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/pages/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/core/pages/search/search_app_bar.dart';
import 'package:boorusama/core/pages/search/search_app_bar_result_view.dart';
import 'package:boorusama/core/pages/search/search_button.dart';
import 'package:boorusama/core/pages/search/search_landing_view.dart';
import 'package:boorusama/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/core/widgets/search_scope.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'widgets/search/result_view.dart';
import 'widgets/search/trending_section.dart';

class DanbooruSearchPage extends ConsumerStatefulWidget {
  const DanbooruSearchPage({
    super.key,
    this.initialQuery,
    this.selectedTagController,
  });

  final String? initialQuery;
  final SelectedTagController? selectedTagController;

  @override
  ConsumerState<DanbooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<DanbooruSearchPage> {
  late final metaTagRegex =
      RegExp('(${ref.watch(metatagsProvider).map((e) => e.name).join('|')})+:');

  @override
  Widget build(BuildContext context) {
    return SearchScope(
      selectedTagController: widget.selectedTagController,
      initialQuery: widget.initialQuery,
      pattern: {
        metaTagRegex: TextStyle(
          fontWeight: FontWeight.w800,
          color: context.colorScheme.primary,
        ),
      },
      builder: (state, focus, controller, selectedTagController,
              searchController, allowSearch) =>
          switch (state) {
        DisplayState.options => Scaffold(
            floatingActionButton: SearchButton(
              allowSearch: allowSearch,
              onSearch: () => searchController.search(),
            ),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
              child: SearchAppBar(
                focusNode: focus,
                queryEditingController: controller,
                onSubmitted: (value) => searchController.submit(value),
                onBack: !context.canPop()
                    ? null
                    : () => state != DisplayState.options
                        ? searchController.resetToOptions()
                        : context.pop(),
              ),
            ),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPinnedHeader(
                    child: SelectedTagListWithData(
                      controller: selectedTagController,
                      onDeleted: (value) => searchController.resetToOptions(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SearchLandingView(
                      onHistoryCleared: () => ref
                          .read(searchHistoryProvider.notifier)
                          .clearHistories(),
                      onHistoryRemoved: (value) => ref
                          .read(searchHistoryProvider.notifier)
                          .removeHistory(value.query),
                      onHistoryTap: (value) =>
                          searchController.tapHistoryTag(value),
                      onTagTap: (value) => searchController.tapTag(value),
                      trendingBuilder: (context) => TrendingSection(
                        onTagTap: (value) {
                          searchController.tapTag(value);
                        },
                      ),
                      metatagsBuilder: (context) => DanbooruMetatagsSection(
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
              textEditingController: controller,
              searchController: searchController,
              selectedTagController: selectedTagController,
            ),
          ),
        DisplayState.result => ResultView(
            selectedTagController: selectedTagController,
            onRelatedTagSelected: (tag, postController) {
              selectedTagController.addTag(tag.tag);
              postController.refresh();
              searchController.search();
            },
            headerBuilder: () => [
              SearchAppBarResultView(
                onTap: () => searchController.goToSuggestions(),
                onBack: () => searchController.resetToOptions(),
              ),
              SliverToBoxAdapter(
                  child: SelectedTagListWithData(
                controller: selectedTagController,
                onDeleted: (value) => searchController.resetToOptions(),
              )),
            ],
          )
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
