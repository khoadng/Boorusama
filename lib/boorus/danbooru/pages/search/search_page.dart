// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/features/posts/app.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/core/ui/search/search_app_bar.dart';
import 'package:boorusama/core/ui/search/search_app_bar_result_view.dart';
import 'package:boorusama/core/ui/search/search_button.dart';
import 'package:boorusama/core/ui/search/search_divider.dart';
import 'package:boorusama/core/ui/search/search_landing_view.dart';
import 'package:boorusama/core/ui/search/selected_tag_list_with_data.dart';
import 'package:boorusama/core/ui/search/tag_suggestion_items.dart';
import 'package:boorusama/core/ui/utils.dart';
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
                  metatagHighlightColor: Theme.of(context).colorScheme.primary,
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
  late final queryEditingController = RichTextController(
    patternMatchMap: {
      ref.read(searchMetatagStringRegexProvider): TextStyle(
        fontWeight: FontWeight.w800,
        color: widget.metatagHighlightColor,
      ),
    },
    // ignore: no-empty-block
    onMatch: (List<String> match) {},
  );
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null) {
        ref
            .read(searchProvider.notifier)
            .skipToResultWithTag(widget.initialQuery!);

        ref
            .read(postCountStateProvider.notifier)
            .getPostCount([widget.initialQuery!]);
      }
    });
  }

  @override
  void dispose() {
    queryEditingController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metatags = ref.watch(metatagsProvider);
    // listen to query provider
    ref.listen(
      sanitizedQueryProvider,
      (prev, curr) {
        if (prev != curr) {
          final displayState = ref.read(searchProvider);
          if (curr.isEmpty && displayState != DisplayState.result) {
            queryEditingController.clear();
          }
        }
      },
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Builder(builder: (context) {
        final displayState = ref.watch(searchProvider);
        final theme = ref.watch(themeProvider);

        switch (displayState) {
          case DisplayState.options:
            return Scaffold(
              floatingActionButton: SearchButton(
                onSearch: () {
                  final tags = ref.read(selectedTagsProvider);
                  final rawTags = tags.map((e) => e.toString()).toList();
                  ref
                      .read(postCountStateProvider.notifier)
                      .getPostCount(rawTags);
                },
              ),
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
                child: SearchAppBar(
                  focusNode: focus,
                  queryEditingController: queryEditingController,
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
                          metatags: metatags,
                          onOptionTap: (value) {
                            ref
                                .read(searchProvider.notifier)
                                .tapRawMetaTag(value);
                            focus.requestFocus();
                            _onTextChanged(queryEditingController, '$value:');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          case DisplayState.suggestion:
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
                child: SearchAppBar(
                  focusNode: focus,
                  queryEditingController: queryEditingController,
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
            );

          case DisplayState.result:
            return ResultView(
              headerBuilder: () => [
                const SearchAppBarResultView(),
                const SliverToBoxAdapter(child: SelectedTagListWithData()),
                const SliverToBoxAdapter(child: SearchDivider(height: 7)),
              ],
            );
        }
      }),
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
