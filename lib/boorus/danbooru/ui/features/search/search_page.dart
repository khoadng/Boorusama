// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/utils.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/search/empty_view.dart';
import 'package:boorusama/core/ui/search/error_view.dart';
import 'package:boorusama/core/ui/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/core/ui/search/search_button.dart';
import 'package:boorusama/core/ui/search/search_landing_view.dart';
import 'package:boorusama/core/ui/search/selected_tag_list.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:boorusama/core/ui/tag_suggestion_items.dart';
import 'landing/trending/trending_section.dart';
import 'result/result_view.dart';

import 'package:boorusama/core/application/search_history.dart'
    hide SearchHistoryCleared;

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.metatags,
    required this.metatagHighlightColor,
    this.autoFocusSearchBar = true,
    required this.pagination,
  });

  final List<Metatag> metatags;
  final Color metatagHighlightColor;
  final bool autoFocusSearchBar;
  final bool pagination;

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
  final focus = FocusNode();

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
              previous.currentQuery.isNotEmpty && current.currentQuery.isEmpty,
          listener: (context, state) {
            queryEditingController.clear();
          },
        ),
      ],
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Screen.of(context).size != ScreenSize.small
            ? _LargeLayout(
                focus: focus,
                autoFocus: widget.autoFocusSearchBar,
                queryEditingController: queryEditingController,
                pagination: widget.pagination,
              )
            : _SmallLayout(
                focus: focus,
                autoFocus: widget.autoFocusSearchBar,
                queryEditingController: queryEditingController,
                pagination: widget.pagination,
              ),
      ),
    );
  }
}

class _LargeLayout extends StatelessWidget {
  const _LargeLayout({
    required this.focus,
    required this.queryEditingController,
    this.autoFocus = true,
    required this.pagination,
  });

  final FocusNode focus;
  final RichTextController queryEditingController;
  final bool autoFocus;
  final bool pagination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const SearchButton(),
      body: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: _AppBar(
                  focusNode: focus,
                  queryEditingController: queryEditingController,
                ),
                body: Column(
                  children: [
                    const _SelectedTagList(),
                    const _Divider(),
                    Expanded(
                      child:
                          BlocSelector<SearchBloc, SearchState, DisplayState>(
                        selector: (state) => state.displayState,
                        builder: (context, displayState) {
                          return displayState == DisplayState.suggestion
                              ? _TagSuggestionItems(
                                  queryEditingController:
                                      queryEditingController,
                                )
                              : _LandingView(
                                  onFocusRequest: () => focus.requestFocus(),
                                  onTextChanged: (text) => _onTextChanged(
                                    queryEditingController,
                                    text,
                                  ),
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: BlocSelector<SearchBloc, SearchState, DisplayState>(
              selector: (state) => state.displayState,
              builder: (context, displayState) {
                switch (displayState) {
                  case DisplayState.options:
                  case DisplayState.suggestion:
                    return const Center(
                      child: Text('Your result will appear here'),
                    );
                  case DisplayState.result:
                    return ResultView(
                      pagination: pagination,
                    );
                  case DisplayState.noResult:
                    return EmptyView(text: 'search.no_result'.tr());
                  case DisplayState.error:
                    return const _ErrorView();
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
    final error = context.select((SearchBloc bloc) => bloc.state.error);

    return ErrorView(text: error?.tr() ?? 'search.errors.generic'.tr());
  }
}

class _SelectedTagList extends StatelessWidget {
  const _SelectedTagList();

  @override
  Widget build(BuildContext context) {
    final tags = context.select((SearchBloc bloc) => bloc.state.selectedTags);

    return SelectedTagList(
      tags: tags,
      onClear: () =>
          context.read<SearchBloc>().add(const SearchSelectedTagCleared()),
      onDelete: (tag) =>
          context.read<SearchBloc>().add(SearchSelectedTagRemoved(tag: tag)),
      onBulkDownload: (tags) => goToBulkDownloadPage(
        context,
        tags.map((e) => e.toString()).toList(),
      ),
    );
  }
}

class _LandingView extends StatelessWidget {
  const _LandingView({
    this.onFocusRequest,
    required this.onTextChanged,
  });

  final VoidCallback? onFocusRequest;
  final void Function(String text) onTextChanged;

  @override
  Widget build(BuildContext context) {
    return SearchLandingView(
      onAddTagRequest: () {
        final bloc = context.read<FavoriteTagBloc>();
        goToQuickSearchPage(
          context,
          onSubmitted: (context, text) {
            Navigator.of(context).pop();
            bloc.add(FavoriteTagAdded(tag: text));
          },
          onSelected: (tag) => bloc.add(FavoriteTagAdded(tag: tag.value)),
        );
      },
      trendingBuilder: (context) => TrendingSection(
        onTagTap: (value) {
          _onTagTap(context, value);
        },
      ),
      onHistoryTap: (value) {
        FocusManager.instance.primaryFocus?.unfocus();
        context.read<SearchBloc>().add(
              SearchHistoryTagSelected(
                tag: value,
              ),
            );
      },
      onTagTap: (value) {
        _onTagTap(context, value);
      },
      onHistoryRemoved: (value) => _onHistoryRemoved(context, value),
      onHistoryCleared: () => _onHistoryCleared(context),
      onFullHistoryRequested: () {
        final searchBloc = context.read<SearchBloc>();

        goToSearchHistoryPage(
          context,
          onClear: () => _onHistoryCleared(context),
          onRemove: (value) => _onHistoryRemoved(context, value),
          onTap: (value) => _onHistoryTap(context, value, searchBloc),
        );
      },
      metatagsBuilder: (context) => DanbooruMetatagsSection(
        onOptionTap: (value) {
          context.read<SearchBloc>().add(
                SearchRawMetatagSelected(
                  tag: value,
                ),
              );
          onFocusRequest?.call();
          onTextChanged.call('$value:');
        },
      ),
    );
  }

  void _onTagTap(BuildContext context, String value) {
    FocusManager.instance.primaryFocus?.unfocus();

    context.read<SearchBloc>().add(SearchRawTagSelected(tag: value));
  }

  void _onHistoryTap(BuildContext context, String value, SearchBloc bloc) {
    Navigator.of(context).pop();
    bloc.add(SearchHistoryTagSelected(tag: value));
  }

  void _onHistoryCleared(BuildContext context) =>
      context.read<SearchBloc>().add(const SearchHistoryCleared());

  void _onHistoryRemoved(BuildContext context, SearchHistory value) =>
      context.read<SearchBloc>().add(SearchHistoryDeleted(history: value));
}

// ignore: prefer_mixin
class _AppBar extends StatelessWidget with PreferredSizeWidget {
  const _AppBar({
    required this.queryEditingController,
    this.focusNode,
    this.autofocus = false,
  });

  final RichTextController queryEditingController;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight * 1.2,
      title: _SearchBar(
        autofocus: autofocus,
        focusNode: focusNode,
        queryEditingController: queryEditingController,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.2);
}

class _SmallLayout extends StatefulWidget {
  const _SmallLayout({
    required this.focus,
    required this.queryEditingController,
    this.autoFocus = true,
    required this.pagination,
  });

  final FocusNode focus;
  final RichTextController queryEditingController;
  final bool autoFocus;
  final bool pagination;

  @override
  State<_SmallLayout> createState() => _SmallLayoutState();
}

class _SmallLayoutState extends State<_SmallLayout> {
  final scrollController = AutoScrollController();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayState =
        context.select((SearchBloc bloc) => bloc.state.displayState);

    switch (displayState) {
      case DisplayState.options:
        return Scaffold(
          floatingActionButton: const SearchButton(),
          appBar: _AppBar(
            autofocus: widget.autoFocus,
            focusNode: widget.focus,
            queryEditingController: widget.queryEditingController,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const _SelectedTagList(),
                  const _Divider(),
                  _LandingView(
                    onFocusRequest: () => widget.focus.requestFocus(),
                    onTextChanged: (text) =>
                        _onTextChanged(widget.queryEditingController, text),
                  ),
                ],
              ),
            ),
          ),
        );
      case DisplayState.suggestion:
        return Scaffold(
          appBar: _AppBar(
            autofocus: true,
            focusNode: widget.focus,
            queryEditingController: widget.queryEditingController,
          ),
          body: SafeArea(
            child: Column(
              children: [
                const _SelectedTagList(),
                const _Divider(),
                Expanded(
                  child: _TagSuggestionItems(
                    queryEditingController: widget.queryEditingController,
                  ),
                ),
              ],
            ),
          ),
        );
      case DisplayState.error:
        return Scaffold(
          appBar: _AppBar(
            focusNode: widget.focus,
            queryEditingController: widget.queryEditingController,
          ),
          body: SafeArea(
            child: Column(
              children: const [
                _SelectedTagList(),
                _Divider(),
                Expanded(child: _ErrorView()),
              ],
            ),
          ),
        );
      case DisplayState.noResult:
        return Scaffold(
          appBar: _AppBar(
            focusNode: widget.focus,
            queryEditingController: widget.queryEditingController,
          ),
          body: SafeArea(
            child: Column(
              children: [
                const _SelectedTagList(),
                const _Divider(),
                Expanded(child: EmptyView(text: 'search.no_result'.tr())),
              ],
            ),
          ),
        );
      case DisplayState.result:
        return ResultView(
          pagination: widget.pagination,
          scrollController: scrollController,
          headerBuilder: () => [
            SliverAppBar(
              titleSpacing: 0,
              toolbarHeight: kToolbarHeight * 1.9,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              shadowColor: Colors.transparent,
              title: SizedBox(
                height: kToolbarHeight * 1.85,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SearchBar(
                        enabled: false,
                        onTap: () => context
                            .read<SearchBloc>()
                            .add(const SearchGoToSuggestionsRequested()),
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.read<SearchBloc>().add(
                                const SearchGoBackToSearchOptionsRequested(),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _SelectedTagList(),
                  ],
                ),
              ),
              floating: true,
              snap: true,
              automaticallyImplyLeading: false,
            ),
            const SliverToBoxAdapter(child: _Divider(height: 7)),
          ],
        );
    }
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

class _TagSuggestionItems extends StatelessWidget {
  const _TagSuggestionItems({
    required this.queryEditingController,
  });

  final TextEditingController queryEditingController;

  @override
  Widget build(BuildContext context) {
    final suggestionTags =
        context.select((SearchBloc bloc) => bloc.state.suggestionTags);
    final currentQuery =
        context.select((SearchBloc bloc) => bloc.state.currentQuery);
    final histories = context
        .select((SearchHistorySuggestionsBloc bloc) => bloc.state.histories);
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return SliverTagSuggestionItemsWithHistory(
      tags: suggestionTags,
      histories: histories,
      currentQuery: currentQuery,
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
      textColorBuilder: (tag) =>
          generateDanbooruAutocompleteTagColor(tag, theme),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({
    this.height,
  });

  final double? height;

  @override
  Widget build(BuildContext context) {
    final tags = context.select((SearchBloc bloc) => bloc.state.selectedTags);

    return tags.isNotEmpty
        ? Divider(height: height ?? 15, thickness: 1)
        : const SizedBox.shrink();
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.queryEditingController,
    this.focusNode,
    this.autofocus = false,
  });

  final RichTextController queryEditingController;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      autofocus: autofocus,
      focus: focusNode,
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
                : Navigator.of(context).pop(),
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
