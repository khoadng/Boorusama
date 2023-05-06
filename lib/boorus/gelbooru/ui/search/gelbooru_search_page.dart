// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/ui/posts.dart';
import 'package:boorusama/boorus/gelbooru/ui/utils.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/application/search_history.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/post_grid_config_icon_button.dart';
import 'package:boorusama/core/ui/posts/post_scope.dart';
import 'package:boorusama/core/ui/search/search_app_bar.dart';
import 'package:boorusama/core/ui/search/search_app_bar_result_view.dart';
import 'package:boorusama/core/ui/search/search_button.dart';
import 'package:boorusama/core/ui/search/search_divider.dart';
import 'package:boorusama/core/ui/search/search_landing_view.dart';
import 'package:boorusama/core/ui/search/selected_tag_list_with_data.dart';
import 'package:boorusama/core/ui/search/tag_suggestion_items.dart';

class GelbooruSearchPage extends ConsumerStatefulWidget {
  const GelbooruSearchPage({
    super.key,
    required this.metatags,
    required this.metatagHighlightColor,
    this.initialQuery,
  });

  final List<Metatag> metatags;
  final Color metatagHighlightColor;
  final String? initialQuery;

  static Route<T> routeOf<T>(
    BuildContext context, {
    String? tag,
  }) {
    final booru = context.read<CurrentBooruBloc>().state.booru!;

    return PageTransition(
      type: PageTransitionType.fade,
      child: GelbooruProvider.of(
        context,
        booru: booru,
        builder: (gcontext) {
          final tagInfo = gcontext.read<TagInfo>();
          final favoriteTagBloc = gcontext.read<FavoriteTagBloc>()
            ..add(const FavoriteTagFetched());

          final searchHistorySuggestions = SearchHistorySuggestionsBloc(
            searchHistoryRepository: context.read<SearchHistoryRepository>(),
          );

          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: favoriteTagBloc),
              BlocProvider.value(value: searchHistorySuggestions),
            ],
            child: CustomContextMenuOverlay(
              child: ProviderScope(
                overrides: [
                  selectedTagsProvider.overrideWith(SelectedTagsNotifier.new)
                ],
                child: GelbooruSearchPage(
                  metatags: tagInfo.metatags,
                  metatagHighlightColor: Theme.of(context).colorScheme.primary,
                  initialQuery: tag,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  ConsumerState<GelbooruSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<GelbooruSearchPage> {
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
    final displayState = ref.watch(searchProvider);
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

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
        switch (displayState) {
          case DisplayState.options:
            return Scaffold(
              floatingActionButton: const SearchButton(),
              appBar: SearchAppBar(
                focusNode: focus,
                queryEditingController: queryEditingController,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      SelectedTagListWithData(),
                      SearchDivider(),
                      SearchLandingView(),
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
                            generateGelbooruAutocompleteTagColor(tag, theme),
                      ),
                    ),
                  ],
                ),
              ),
            );
          case DisplayState.result:
            return const _ResultView();
        }
      }),
    );
  }
}

class _ResultView extends ConsumerWidget {
  const _ResultView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(selectedRawTagStringProvider);

    return PostScope(
      fetcher: (page) => context.read<PostRepository>().getPostsFromTags(
            selectedTags.join(' '),
            page,
          ),
      builder: (context, controller, errors) => GelbooruInfinitePostList(
        errors: errors,
        controller: controller,
        sliverHeaderBuilder: (context) => [
          const SearchAppBarResultView(),
          const SliverToBoxAdapter(child: SearchDivider(height: 7)),
          SliverToBoxAdapter(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: PostGridConfigIconButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
