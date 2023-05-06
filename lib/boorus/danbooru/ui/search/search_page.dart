// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/boorus/danbooru/ui/utils.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/core/ui/search/search_app_bar.dart';
import 'package:boorusama/core/ui/search/search_app_bar_result_view.dart';
import 'package:boorusama/core/ui/search/search_button.dart';
import 'package:boorusama/core/ui/search/search_divider.dart';
import 'package:boorusama/core/ui/search/search_landing_view.dart';
import 'package:boorusama/core/ui/search/selected_tag_list_with_data.dart';
import 'package:boorusama/core/ui/search/tag_suggestion_items.dart';
import 'landing/trending/trending_section.dart';
import 'result/result_view.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({
    super.key,
    required this.metatags,
    required this.metatagHighlightColor,
    this.initialQuery,
  });

  final List<Metatag> metatags;
  final Color metatagHighlightColor;
  final String? initialQuery;

  static Route<T> routeOf<T>(BuildContext context, {String? tag}) {
    return PageTransition(
        type: PageTransitionType.fade,
        child: BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (_, state) {
            return DanbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (context) {
                final relatedTagBloc = RelatedTagBloc(
                  relatedTagRepository: context.read<RelatedTagRepository>(),
                );

                return MultiBlocProvider(
                  providers: [
                    BlocProvider.value(
                      value: context.read<FavoriteTagBloc>()
                        ..add(const FavoriteTagFetched()),
                    ),
                    BlocProvider.value(
                      value: BlocProvider.of<ThemeBloc>(context),
                    ),
                    BlocProvider.value(value: relatedTagBloc),
                  ],
                  child: CustomContextMenuOverlay(
                    child: ProviderScope(
                      overrides: [
                        selectedTagsProvider
                            .overrideWith(SelectedTagsNotifier.new),
                      ],
                      child: SearchPage(
                        metatags: context.read<TagInfo>().metatags,
                        metatagHighlightColor:
                            Theme.of(context).colorScheme.primary,
                        initialQuery: tag,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final _tags = widget.metatags.map((e) => e.name).join('|');
  late final queryEditingController = RichTextController(
    patternMatchMap: {
      RegExp('($_tags)+:'): TextStyle(
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
        final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

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
              appBar: SearchAppBar(
                focusNode: focus,
                queryEditingController: queryEditingController,
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
                          metatags: widget.metatags,
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
              appBar: SearchAppBar(
                focusNode: focus,
                queryEditingController: queryEditingController,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    const SelectedTagListWithData(),
                    const SearchDivider(),
                    Expanded(
                      child: TagSuggestionItemsWithData(
                        textColorBuilder: (tag) =>
                            generateDanbooruAutocompleteTagColor(tag, theme),
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
