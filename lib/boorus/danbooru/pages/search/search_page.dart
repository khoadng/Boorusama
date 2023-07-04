// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/feats/utils.dart';
import 'package:boorusama/boorus/core/pages/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar_result_view.dart';
import 'package:boorusama/boorus/core/pages/search/search_button.dart';
import 'package:boorusama/boorus/core/pages/search/search_divider.dart';
import 'package:boorusama/boorus/core/pages/search/search_landing_view.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/boorus/core/pages/search/tag_suggestion_items.dart';
import 'package:boorusama/boorus/core/widgets/search_scope.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/flutter.dart';
import 'landing/trending/trending_section.dart';
import 'result/result_view.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({
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
              child: ProviderScope(
                overrides: [
                  selectedTagsProvider.overrideWith(SelectedTagsNotifier.new),
                ],
                child: SearchPage(
                  metatagHighlightColor: context.colorScheme.primary,
                  initialQuery: tag,
                ),
              ),
            );
          },
        ));
  }

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
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
      builder: (state, theme, focus, controller) => switch (state) {
        DisplayState.options => Scaffold(
            floatingActionButton: SearchButton(
              onSearch: () {
                final tags = ref.read(selectedTagsProvider);
                final rawTags = tags.map((e) => e.toString()).toList();
                ref.read(postCountStateProvider.notifier).getPostCount(rawTags);
              },
            ),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
              child: SearchAppBar(
                focusNode: focus,
                queryEditingController: controller,
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SelectedTagListWithData(),
                    const SearchDivider(),
                    SearchLandingView(
                      trendingBuilder: (context) => TrendingSection(
                        onTagTap: (value) {
                          ref.read(searchProvider.notifier).tapTag(value);
                        },
                      ),
                      metatagsBuilder: (context) => DanbooruMetatagsSection(
                        onOptionTap: (value) {
                          ref
                              .read(searchProvider.notifier)
                              .tapRawMetaTag(value);
                          focus.requestFocus();
                          _onTextChanged(controller, '$value:');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        DisplayState.suggestion => Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
              child: SearchAppBar(
                focusNode: focus,
                queryEditingController: controller,
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const SelectedTagListWithData(),
                  const SearchDivider(),
                  Expanded(
                    child: TagSuggestionItemsWithData(
                      textColorBuilder: (tag) =>
                          generateAutocompleteTagColor(tag, theme),
                    ),
                  ),
                ],
              ),
            ),
          ),
        DisplayState.result => ResultView(
            headerBuilder: () => [
              const SearchAppBarResultView(),
              const SliverToBoxAdapter(child: SelectedTagListWithData()),
              const SliverToBoxAdapter(child: SearchDivider(height: 7)),
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
