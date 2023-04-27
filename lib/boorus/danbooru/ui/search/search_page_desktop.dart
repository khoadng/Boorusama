// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/utils.dart';
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/search/empty_view.dart';
import 'package:boorusama/core/ui/search/error_view.dart';
import 'package:boorusama/core/ui/search/full_history_view.dart';
import 'package:boorusama/core/ui/search/metatags/danbooru_metatags_section.dart';
import 'package:boorusama/core/ui/search/search_landing_view.dart';
import 'package:boorusama/core/ui/search/selected_tag_list.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:boorusama/core/ui/tag_suggestion_items.dart';
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';
import 'landing/trending/trending_section.dart';
import 'result/result_view.dart';

import 'package:boorusama/core/application/search_history.dart'
    hide SearchHistoryCleared;

class SearchPageDesktop extends StatefulWidget {
  const SearchPageDesktop({
    super.key,
    required this.metatags,
    required this.metatagHighlightColor,
    required this.pagination,
  });

  final List<Metatag> metatags;
  final Color metatagHighlightColor;
  final bool pagination;

  @override
  State<SearchPageDesktop> createState() => _SearchPageDesktopState();
}

class _SearchPageDesktopState extends State<SearchPageDesktop> {
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<SearchBloc>().add(const SearchRequested());
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
              previous.currentQuery.isNotEmpty && current.currentQuery.isEmpty,
          listener: (context, state) {
            queryEditingController.clear();
          },
        ),
      ],
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _LargeLayout(
          focus: focus,
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
    required this.pagination,
  });

  final FocusNode focus;
  final RichTextController queryEditingController;
  final bool pagination;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).cardColor,
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: false,
            toolbarHeight: kToolbarHeight * 1.2,
            title: BlocSelector<SearchBloc, SearchState, DisplayState>(
              selector: (state) => state.displayState,
              builder: (context, displayState) {
                return PortalTarget(
                  visible: displayState == DisplayState.suggestion,
                  anchor: const Aligned(
                    offset: Offset(0, 8),
                    follower: Alignment.topCenter,
                    target: Alignment.bottomCenter,
                  ),
                  portalFollower: SizedBox(
                    width: min(500, MediaQuery.of(context).size.width),
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Material(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _TagSuggestionItems(
                          queryEditingController: queryEditingController,
                        ),
                      ),
                    ),
                  ),
                  child: SearchBar(
                    constraints: const BoxConstraints(maxWidth: 500),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    autofocus: true,
                    focus: focus,
                    queryEditingController: queryEditingController,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
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
                          : const _SearchButton(),
                    ),
                    onChanged: (value) {
                      context
                          .read<SearchBloc>()
                          .add(SearchQueryChanged(query: value));
                    },
                    onSubmitted: (value) => context
                        .read<SearchBloc>()
                        .add(const SearchQuerySubmitted()),
                  ),
                );
              },
            ),
          ),
          body: Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  resizeToAvoidBottomInset: false,
                  body: Column(
                    children: [
                      Expanded(
                        child:
                            BlocSelector<SearchBloc, SearchState, DisplayState>(
                          selector: (state) => state.displayState,
                          builder: (context, displayState) {
                            return _LandingView(
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
              const VerticalDivider(),
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: _SelectedTagList(),
                    ),
                    Expanded(
                      child:
                          BlocSelector<SearchBloc, SearchState, DisplayState>(
                        selector: (state) => state.displayState,
                        builder: (context, displayState) {
                          switch (displayState) {
                            case DisplayState.options:
                              return const Center(
                                child: Text('Your result will appear here'),
                              );
                            case DisplayState.suggestion:
                            case DisplayState.result:
                              return ResultView(
                                pagination: pagination,
                                backgroundColor:
                                    Theme.of(context).colorScheme.background,
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context) {
    final allowSearch =
        context.select((SearchBloc bloc) => bloc.state.allowSearch);

    return ConditionalRenderWidget(
      condition: allowSearch,
      childBuilder: (context) => IconButton(
        onPressed: () =>
            context.read<SearchBloc>().add(const SearchRequested()),
        icon: const Icon(Icons.search),
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
      onBulkDownload: (tags) =>
          goToBulkDownloadPage(context, tags.map((e) => e.toString()).toList()),
    );
  }
}

class _LandingView extends StatefulWidget {
  const _LandingView({
    this.onFocusRequest,
    required this.onTextChanged,
  });

  final VoidCallback? onFocusRequest;
  final void Function(String text) onTextChanged;

  @override
  State<_LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<_LandingView> {
  var inHistoryMode = false;

  @override
  Widget build(BuildContext context) {
    return inHistoryMode
        ? BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
            builder: (context, state) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'search.history.recent'.tr(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _onHistoryCleared(context),
                          child: const Text('search.history.clear').tr(),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () =>
                              setState(() => inHistoryMode = false),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: FullHistoryView(
                      useAppbar: false,
                      onHistoryTap: (value) => _onHistoryTap(context, value),
                      onHistoryRemoved: (value) =>
                          _onHistoryRemoved(context, value),
                      onHistoryFiltered: (value) => context
                          .read<SearchHistoryBloc>()
                          .add(SearchHistoryFiltered(value)),
                      histories: state.filteredhistories,
                    ),
                  ),
                ],
              );
            },
          )
        : SearchLandingView(
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
                _onHistoryTap(context, value);
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
            onTagTap: (value) => _onHistoryTap(context, value),
            onHistoryRemoved: (value) => _onHistoryRemoved(context, value),
            onHistoryCleared: () => _onHistoryCleared(context),
            onFullHistoryRequested: () => setState(() => inHistoryMode = true),
            metatagsBuilder: (context) => DanbooruMetatagsSection(
              onOptionTap: (value) {
                context.read<SearchBloc>().add(
                      SearchRawMetatagSelected(
                        tag: value,
                      ),
                    );
                widget.onFocusRequest?.call();
                widget.onTextChanged.call('$value:');
              },
            ),
          );
  }

  void _onHistoryTap(BuildContext context, String value) =>
      context.read<SearchBloc>().add(SearchHistoryTagSelected(tag: value));

  void _onHistoryCleared(BuildContext context) =>
      context.read<SearchBloc>().add(const SearchHistoryCleared());

  void _onHistoryRemoved(BuildContext context, SearchHistory value) =>
      context.read<SearchBloc>().add(SearchHistoryDeleted(history: value));
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
