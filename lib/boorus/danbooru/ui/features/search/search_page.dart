// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/search_options.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/search/search.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'result_view.dart';
import 'search_button.dart';
import 'selected_tag_list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.metatags,
    required this.metatagHighlightColor,
  });

  final List<Metatag> metatags;
  final Color metatagHighlightColor;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
  final compositeSubscription = CompositeSubscription();
  final FocusNode focus = FocusNode();

  @override
  void initState() {
    super.initState();

    queryEditingController.addListener(() {
      queryEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: queryEditingController.text.length),
      );
    });
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
        BlocListener<SearchBloc, SearchState>(
          listenWhen: (previous, current) =>
              previous.currentQuery != current.currentQuery,
          listener: (context, state) {
            queryEditingController.text = state.currentQuery;
          },
        ),
      ],
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Screen.of(context).size != ScreenSize.small
            ? _LargeLayout(
                focus: focus,
                queryEditingController: queryEditingController,
              )
            : _SmallLayout(
                focus: focus,
                queryEditingController: queryEditingController,
              ),
      ),
    );
  }
}

class _LargeLayout extends StatelessWidget {
  const _LargeLayout({
    required this.focus,
    required this.queryEditingController,
  });

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
                queryEditingController: queryEditingController,
              ),
              body: Column(
                children: [
                  const _SelectedTagList(),
                  const _Divider(),
                  Expanded(
                    child: BlocSelector<SearchBloc, SearchState, DisplayState>(
                      selector: (state) => state.displayState,
                      builder: (context, displayState) {
                        return displayState == DisplayState.suggestion
                            ? _TagSuggestionItems(
                                queryEditingController: queryEditingController,
                              )
                            : const _SearchOptions();
                      },
                    ),
                  ),
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
                  return const _ErrorView();
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

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchBloc, SearchState, String?>(
      selector: (state) => state.error,
      builder: (context, error) {
        return ErrorView(text: error?.tr() ?? 'search.errors.generic'.tr());
      },
    );
  }
}

class _SelectedTagList extends StatelessWidget {
  const _SelectedTagList();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchBloc, SearchState, List<TagSearchItem>>(
      selector: (state) => state.selectedTags,
      builder: (context, tags) {
        return SelectedTagList(
          tags: tags,
          onClear: () =>
              context.read<SearchBloc>().add(const SearchSelectedTagCleared()),
          onDelete: (tag) => context
              .read<SearchBloc>()
              .add(SearchSelectedTagRemoved(tag: tag)),
          onBulkDownload: (tags) => AppRouter.router.navigateTo(
            context,
            '/bulk_download',
            routeSettings: RouteSettings(
              arguments: [
                tags.map((e) => e.toString()).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchOptions extends StatelessWidget {
  const _SearchOptions();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchBloc, SearchState, List<Metatag>>(
      selector: (state) => state.metatags,
      builder: (context, metatags) {
        return SearchOptions(
          metatags: metatags,
          onOptionTap: (value) {
            context.read<SearchBloc>().add(
                  SearchRawMetatagSelected(
                    tag: value,
                  ),
                );
          },
          onHistoryTap: (value) {
            FocusManager.instance.primaryFocus?.unfocus();
            context.read<SearchBloc>().add(
                  SearchHistoryTagSelected(
                    tag: value,
                  ),
                );
          },
          onTagTap: (value) {
            FocusManager.instance.primaryFocus?.unfocus();
            context.read<SearchBloc>().add(SearchRawTagSelected(tag: value));
          },
        );
      },
    );
  }
}

// ignore: prefer_mixin
class _AppBar extends StatelessWidget with PreferredSizeWidget {
  const _AppBar({
    required this.queryEditingController,
  });

  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: _SearchBar(
        queryEditingController: queryEditingController,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.2);
}

class _SmallLayout extends StatelessWidget {
  const _SmallLayout({
    required this.focus,
    required this.queryEditingController,
  });

  final FocusNode focus;
  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: const SearchButton(),
      appBar: _AppBar(
        queryEditingController: queryEditingController,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _SelectedTagList(),
            const _Divider(),
            Expanded(
              child: BlocSelector<SearchBloc, SearchState, DisplayState>(
                selector: (state) => state.displayState,
                builder: (context, displayState) {
                  if (displayState == DisplayState.suggestion) {
                    return _TagSuggestionItems(
                      queryEditingController: queryEditingController,
                    );
                  } else if (displayState == DisplayState.result) {
                    return const ResultView();
                  } else if (displayState == DisplayState.error) {
                    return const _ErrorView();
                  } else if (displayState == DisplayState.loadingResult) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (displayState == DisplayState.noResult) {
                    return EmptyView(text: 'search.no_result'.tr());
                  } else {
                    return const _SearchOptions();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagSuggestionItems extends StatelessWidget {
  const _TagSuggestionItems({
    required this.queryEditingController,
  });

  final TextEditingController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, searchState) {
        return BlocBuilder<SearchHistorySuggestionsBloc,
            SearchHistorySuggestionsState>(
          builder: (context, state) {
            return SliverTagSuggestionItemsWithHistory(
              tags: searchState.suggestionTags,
              histories: state.histories,
              currentQuery: searchState.currentQuery,
              onHistoryDeleted: (history) {
                context
                    .read<SearchBloc>()
                    .add(SearchHistoryDeleted(history: history.searchHistory));
              },
              onHistoryTap: (history) {
                FocusManager.instance.primaryFocus?.unfocus();
                context
                    .read<SearchBloc>()
                    .add(SearchHistoryTagSelected(tag: history.tag));
              },
              onItemTap: (tag) {
                FocusManager.instance.primaryFocus?.unfocus();
                context.read<SearchBloc>().add(SearchTagSelected(tag: tag));
              },
            );
          },
        );
      },
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SearchBloc, SearchState, List<TagSearchItem>>(
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
    required this.queryEditingController,
  });

  final RichTextController queryEditingController;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      queryEditingController: queryEditingController,
      leading: BlocSelector<SearchBloc, SearchState, DisplayState>(
        selector: (state) => state.displayState,
        builder: (context, state) {
          return IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => state != DisplayState.options
                ? context
                    .read<SearchBloc>()
                    .add(const SearchGoBackToSearchOptionsRequested())
                : AppRouter.router.pop(context),
          );
        },
      ),
      trailing: BlocSelector<SearchBloc, SearchState, String>(
        selector: (state) => state.currentQuery,
        builder: (context, query) => query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context
                    .read<SearchBloc>()
                    .add(const SearchQueryChanged(query: '')),
              )
            : const SizedBox.shrink(),
      ),
      onChanged: (value) {
        context.read<SearchBloc>().add(SearchQueryChanged(query: value));
      },
      onSubmitted: (value) =>
          context.read<SearchBloc>().add(const SearchQuerySubmitted()),
    );
  }
}
