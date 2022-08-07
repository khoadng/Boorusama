// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/autocomplete/autocomplete.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/configs/i_config.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/search_options.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/search/selected_tag_chip.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'result_view.dart';
import 'search_button.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    Key? key,
    this.initialQuery = '',
    required this.metatags,
    required this.metatagHighlightColor,
  }) : super(key: key);

  final String initialQuery;
  final List<String> metatags;
  final Color metatagHighlightColor;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final _tags = widget.metatags.join('|');
  late final queryEditingController = RichTextController(
    patternMatchMap: {
      RegExp('($_tags)+:'): TextStyle(
        fontWeight: FontWeight.w800,
        color: widget.metatagHighlightColor,
      ),
    },
    onMatch: (List<String> match) {},
  );
  final compositeSubscription = CompositeSubscription();
  final FocusNode focus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<TagSearchBloc>()
            .add(TagSearchNewRawStringTagSelected(widget.initialQuery));
        context.read<SearchBloc>().add(const SearchRequested());
        context.read<PostBloc>().add(PostRefreshed(tag: widget.initialQuery));
      });
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        focus.requestFocus();
      });
    }

    context.read<SearchHistoryCubit>().getSearchHistory();

    queryEditingController.addListener(() {
      queryEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: queryEditingController.text.length));
    });

    Rx.combineLatest2<SearchState, PostState, Tuple2<SearchState, PostState>>(
            context.read<SearchBloc>().stream,
            context.read<PostBloc>().stream,
            (a, b) => Tuple2(a, b))
        .where((event) =>
            event.item2.status == LoadStatus.failure &&
            event.item1.displayState == DisplayState.result)
        .listen((state) {
      context.read<SearchBloc>().add(const SearchError());
      showSimpleSnackBar(
        context: context,
        duration: const Duration(seconds: 6),
        content: Text(
          state.item2.exceptionMessage!,
        ).tr(),
      );
    }).addTo(compositeSubscription);

    Rx.combineLatest2<SearchState, PostState, Tuple2<SearchState, PostState>>(
            context.read<SearchBloc>().stream,
            context.read<PostBloc>().stream,
            (a, b) => Tuple2(a, b))
        .where((event) =>
            event.item2.status == LoadStatus.success &&
            event.item2.posts.isEmpty &&
            event.item1.displayState == DisplayState.result)
        .listen((state) {
      context.read<SearchBloc>().add(const SearchNoData());
    }).addTo(compositeSubscription);
  }

  @override
  void dispose() {
    compositeSubscription.dispose();
    queryEditingController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TagSearchBloc, TagSearchState>(
          listenWhen: (previous, current) => current.query.isEmpty,
          listener: (context, state) {
            context.read<SearchBloc>().add(const SearchQueryEmpty());
            context.read<TagSearchBloc>().add(const TagSearchCleared());
            queryEditingController.clear();
          },
        ),
        BlocListener<TagSearchBloc, TagSearchState>(
          listenWhen: (previous, current) => current.suggestionTags.isNotEmpty,
          listener: (context, state) {
            context.read<SearchBloc>().add(const SearchSuggestionReceived());
          },
        ),
        BlocListener<TagSearchBloc, TagSearchState>(
          listenWhen: (previous, current) =>
              current.selectedTags.isEmpty && previous.selectedTags.length == 1,
          listener: (context, state) =>
              context.read<SearchBloc>().add(const SearchSelectedTagCleared()),
        ),
        BlocListener<TagSearchBloc, TagSearchState>(
            listenWhen: (previous, current) =>
                current.selectedTags != previous.selectedTags,
            listener: (context, state) {
              final tags =
                  state.selectedTags.map((e) => e.toString()).join(' ');

              context.read<PostBloc>().add(PostRefreshed(tag: tags));
              context
                  .read<RelatedTagBloc>()
                  .add(RelatedTagRequested(query: tags));
            }),
      ],
      child: Screen.of(context).size != ScreenSize.small
          ? _LargeLayout(
              focus: focus,
              queryEditingController: queryEditingController,
            )
          : _SmallLayout(
              focus: focus,
              queryEditingController: queryEditingController,
            ),
    );
  }
}

class _LargeLayout extends StatelessWidget {
  const _LargeLayout({
    Key? key,
    required this.focus,
    required this.queryEditingController,
  }) : super(key: key);

  final FocusNode focus;
  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const SearchButton(),
      body: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: _AppBar(
                focus: focus,
                queryEditingController: queryEditingController,
              ),
              body: Column(
                children: [
                  const _SelectedTagChips(),
                  const _Divider(),
                  Expanded(
                    child: BlocSelector<SearchBloc, SearchState, DisplayState>(
                      selector: (state) => state.displayState,
                      builder: (context, displayState) {
                        if (displayState == DisplayState.suggestion) {
                          return const _TagSuggestionItems();
                        } else {
                          return SearchOptions(
                            config: context.read<IConfig>(),
                            onOptionTap: (value) {
                              context
                                  .read<TagSearchBloc>()
                                  .add(TagSearchChanged(value));
                              queryEditingController.text = '$value:';
                            },
                            onHistoryTap: (value) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              context
                                  .read<TagSearchBloc>()
                                  .add(TagSearchTagFromHistorySelected(value));
                            },
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: BlocSelector<SearchBloc, SearchState, DisplayState>(
              selector: (state) => state.displayState,
              builder: (context, displayState) {
                if (displayState == DisplayState.result) {
                  return const ResultView();
                } else if (displayState == DisplayState.error) {
                  return ErrorView(text: 'search.errors.generic'.tr());
                } else if (displayState == DisplayState.loadingResult) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (displayState == DisplayState.noResult) {
                  return EmptyView(text: 'search.no_result'.tr());
                } else {
                  return const Center(
                    child: Text('Your result will appear here'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: prefer_mixin
class _AppBar extends StatelessWidget with PreferredSizeWidget {
  const _AppBar({
    Key? key,
    required this.focus,
    required this.queryEditingController,
  }) : super(key: key);

  final FocusNode focus;
  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: _SearchBar(
        focus: focus,
        queryEditingController: queryEditingController,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.2);
}

class _SmallLayout extends StatelessWidget {
  const _SmallLayout({
    Key? key,
    required this.focus,
    required this.queryEditingController,
  }) : super(key: key);

  final FocusNode focus;
  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: const SearchButton(),
      appBar: _AppBar(
        focus: focus,
        queryEditingController: queryEditingController,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _SelectedTagChips(),
            const _Divider(),
            Expanded(
              child: BlocSelector<SearchBloc, SearchState, DisplayState>(
                selector: (state) => state.displayState,
                builder: (context, displayState) {
                  if (displayState == DisplayState.suggestion) {
                    return const _TagSuggestionItems();
                  } else if (displayState == DisplayState.result) {
                    return const ResultView();
                  } else if (displayState == DisplayState.error) {
                    return ErrorView(text: 'search.errors.generic'.tr());
                  } else if (displayState == DisplayState.loadingResult) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (displayState == DisplayState.noResult) {
                    return EmptyView(text: 'search.no_result'.tr());
                  } else {
                    return SearchOptions(
                      config: context.read<IConfig>(),
                      onOptionTap: (value) {
                        context
                            .read<TagSearchBloc>()
                            .add(TagSearchChanged(value));
                        queryEditingController.text = '$value:';
                      },
                      onHistoryTap: (value) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        context
                            .read<TagSearchBloc>()
                            .add(TagSearchTagFromHistorySelected(value));
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TagSuggestionItems extends StatelessWidget {
  const _TagSuggestionItems({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TagSearchBloc, TagSearchState, List<AutocompleteData>>(
      selector: (state) => state.suggestionTags,
      builder: (context, tags) {
        return BlocBuilder<SearchHistorySuggestionsBloc,
            SearchHistorySuggestionsState>(
          builder: (context, state) {
            return SliverTagSuggestionItemsWithHistory(
              tags: tags,
              histories: state.histories,
              onHistoryTap: (history) {
                FocusManager.instance.primaryFocus?.unfocus();
                context
                    .read<TagSearchBloc>()
                    .add(TagSearchTagFromHistorySelected(history.tag));
              },
              onItemTap: (tag) {
                FocusManager.instance.primaryFocus?.unfocus();
                context.read<TagSearchBloc>().add(TagSearchNewTagSelected(tag));
              },
            );
          },
        );
      },
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TagSearchBloc, TagSearchState, List<TagSearchItem>>(
      selector: (state) => state.selectedTags,
      builder: (context, tags) => tags.isNotEmpty
          ? const Divider(
              height: 15,
              thickness: 1,
            )
          : const SizedBox.shrink(),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    Key? key,
    required this.focus,
    required this.queryEditingController,
  }) : super(key: key);

  final FocusNode focus;
  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      focus: focus,
      queryEditingController: queryEditingController,
      leading: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => state.displayState != DisplayState.options
                ? context
                    .read<SearchBloc>()
                    .add(const SearchGoBackToSearchOptionsRequested())
                : AppRouter.router.pop(context),
          );
        },
      ),
      trailing: BlocBuilder<TagSearchBloc, TagSearchState>(
        builder: (context, state) => state.query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () =>
                    context.read<TagSearchBloc>().add(const TagSearchCleared()),
              )
            : const SizedBox.shrink(),
      ),
      onChanged: (value) {
        context.read<TagSearchBloc>().add(TagSearchChanged(value));
        context
            .read<SearchHistorySuggestionsBloc>()
            .add(SearchHistorySuggestionsFetched(text: value));
      },
      onSubmitted: (value) =>
          context.read<TagSearchBloc>().add(const TagSearchSubmitted()),
    );
  }
}

class _SelectedTagChips extends StatelessWidget {
  const _SelectedTagChips({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TagSearchBloc, TagSearchState, List<TagSearchItem>>(
      selector: (state) => state.selectedTags,
      builder: (context, tags) => tags.isNotEmpty
          ? Container(
              margin: const EdgeInsets.only(left: 8),
              height: 35,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SelectedTagChip(
                      tagSearchItem: tags[index],
                    ),
                  );
                },
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
