// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/pages/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar_result_view.dart';
import 'package:boorusama/boorus/core/pages/search/search_button.dart';
import 'package:boorusama/boorus/core/pages/search/search_landing_view.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/search_scope.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'landing/trending/trending_section.dart';
import 'result/result_view.dart';

class DanbooruSearchPage extends ConsumerStatefulWidget {
  const DanbooruSearchPage({
    super.key,
    this.initialQuery,
    this.selectedTagController,
  });

  final String? initialQuery;
  final SelectedTagController? selectedTagController;

  static Route<T> routeOf<T>(BuildContext context, {String? tag}) {
    return PageTransition(
        type: PageTransitionType.fade,
        child: CustomContextMenuOverlay(
          child: DanbooruSearchPage(
            initialQuery: tag,
          ),
        ));
  }

  @override
  ConsumerState<DanbooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<DanbooruSearchPage> {
  late final metaTagRegex =
      RegExp('(${ref.watch(metatagsProvider).map((e) => e.name).join('|')})+:');

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null) {
        ref
            .read(postCountStateProvider(ref.read(currentBooruConfigProvider))
                .notifier)
            .getPostCount([widget.initialQuery!]);

        ref
            .read(danbooruRelatedTagsProvider.notifier)
            .fetch(widget.initialQuery!);
      }
    });
  }

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
              onSearch: () =>
                  _onSearch(searchController, selectedTagController),
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
                        : context.navigator.pop(),
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
                    : context.navigator.pop(),
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
              _onSearch(searchController, selectedTagController);
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

  void _onSearch(
    SearchPageController searchController,
    SelectedTagController selectedTagController,
  ) {
    ref
        .read(danbooruRelatedTagsProvider.notifier)
        .fetch(selectedTagController.rawTagsString);
    ref
        .read(postCountStateProvider(ref.read(currentBooruConfigProvider))
            .notifier)
        .getPostCount(selectedTagController.rawTags);
    searchController.search();
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
