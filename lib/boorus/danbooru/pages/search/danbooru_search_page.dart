// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/pages/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar_result_view.dart';
import 'package:boorusama/boorus/core/pages/search/search_button.dart';
import 'package:boorusama/boorus/core/pages/search/search_landing_view.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/boorus/core/widgets/search_scope.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/flutter.dart';
import 'landing/trending/trending_section.dart';
import 'result/result_view.dart';

class DanbooruSearchPage extends ConsumerStatefulWidget {
  const DanbooruSearchPage({
    super.key,
    required this.metatagHighlightColor,
    this.initialQuery,
  });

  final Color metatagHighlightColor;
  final String? initialQuery;

  static Route<T> routeOf<T>(BuildContext context, {String? tag}) {
    return PageTransition(
        type: PageTransitionType.fade,
        child: DanbooruProvider(
          builder: (_) {
            return CustomContextMenuOverlay(
              child: DanbooruSearchPage(
                metatagHighlightColor: context.colorScheme.primary,
                initialQuery: tag,
              ),
            );
          },
        ));
  }

  @override
  ConsumerState<DanbooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<DanbooruSearchPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null) {
        ref
            .read(postCountStateProvider.notifier)
            .getPostCount([widget.initialQuery!]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SearchScope(
      initialQuery: widget.initialQuery,
      pattern: {
        ref.read(searchMetatagStringRegexProvider): TextStyle(
          fontWeight: FontWeight.w800,
          color: widget.metatagHighlightColor,
        ),
      },
      builder: (state, theme, focus, controller, selectedTagController,
              searchController, allowSearch) =>
          switch (state) {
        DisplayState.options => Scaffold(
            floatingActionButton: SearchButton(
              allowSearch: allowSearch,
              onSearch: () {
                ref
                    .read(postCountStateProvider.notifier)
                    .getPostCount(selectedTagController.rawTags);
                searchController.search();
              },
            ),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
              child: SearchAppBar(
                focusNode: focus,
                queryEditingController: controller,
                onSubmitted: (value) => searchController.submit(value),
                // onChanged: (value) =>
                //     ref.read(searchQueryProvider.notifier).state = value,
                onClear: () {
                  controller.clear();
                  // ref.read(searchQueryProvider.notifier).state = '';
                },
                onBack: () => state != DisplayState.options
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
                      searchController: searchController,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SearchLandingView(
                      searchController: searchController,
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
                // onChanged: (value) =>
                //     ref.read(searchQueryProvider.notifier).state = value,
                onClear: () {
                  controller.clear();
                  // ref.read(searchQueryProvider.notifier).state = '';
                },
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
            headerBuilder: () => [
              SearchAppBarResultView(
                onTap: () => searchController.goToSuggestions(),
                onBack: () => searchController.resetToOptions(),
              ),
              SliverToBoxAdapter(
                  child: SelectedTagListWithData(
                controller: selectedTagController,
                searchController: searchController,
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
