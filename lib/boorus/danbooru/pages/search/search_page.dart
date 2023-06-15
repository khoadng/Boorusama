// Flutter imports:
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
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
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/flutter.dart';
import 'landing/trending/trending_section.dart';
import 'result/result_view.dart';

final tabsProvider = StateProvider.autoDispose<List<String>>((ref) {
  return ['0'];
});

final indexProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

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
                child: SearchPage(),
              ),
            );
          },
        ));
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  @override
  Widget build(BuildContext context) {
    final index = ref.watch(indexProvider);
    final tabs = ref.watch(tabsProvider);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: index,
            children: [
              ...tabs.map(
                (e) => ProviderScope(
                  overrides: [
                    selectedTagsProvider.overrideWith(SelectedTagsNotifier.new),
                  ],
                  child: SearchPageInner(
                    metatagHighlightColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50,
              color: Theme.of(context).cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...tabs.mapIndexed((i, e) => Container(
                              color: index == i ? Colors.blue : null,
                              child: Row(
                                children: [
                                  TextButton(
                                    onPressed: () => ref
                                        .read(indexProvider.notifier)
                                        .state = i,
                                    child: Text(e),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      final a = [...ref.read(tabsProvider)];
                                      a.removeAt(i);
                                      ref.read(tabsProvider.notifier).state = a;
                                    },
                                    icon: Icon(Icons.close),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(tabsProvider.notifier).state = [
                        ...ref.read(tabsProvider),
                        (tabs.length).toString(),
                      ];
                    },
                    icon: const Icon(Icons.add),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchPageInner extends ConsumerStatefulWidget {
  const SearchPageInner({
    super.key,
    required this.metatagHighlightColor,
    this.initialQuery,
  });

  final Color metatagHighlightColor;
  final String? initialQuery;

  @override
  ConsumerState<SearchPageInner> createState() => _SearchPageInnerState();
}

class _SearchPageInnerState extends ConsumerState<SearchPageInner> {
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
      searchQueryProvider,
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
      onTap: () => context.focusScope.unfocus(),
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
