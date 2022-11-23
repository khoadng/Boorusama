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
import 'package:boorusama/boorus/danbooru/ui/features/search/landing/landing_view.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'result/result_view.dart';
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
                focusNode: focus,
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
                    return const ResultView();
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
    return LandingView(
      onOptionTap: (value) {
        context.read<SearchBloc>().add(
              SearchRawMetatagSelected(
                tag: value,
              ),
            );
        onFocusRequest?.call();
        onTextChanged.call('$value:');
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
      onHistoryRemoved: (value) {
        context.read<SearchBloc>().add(SearchHistoryDeleted(history: value));
      },
    );
  }
}

// ignore: prefer_mixin
class _AppBar extends StatelessWidget with PreferredSizeWidget {
  const _AppBar({
    required this.queryEditingController,
    this.focusNode,
  });

  final RichTextController queryEditingController;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: _SearchBar(
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
  });

  final FocusNode focus;
  final RichTextController queryEditingController;

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
                _ErrorView(),
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
                EmptyView(text: 'search.no_result'.tr()),
              ],
            ),
          ),
        );
      case DisplayState.result:
        return ResultView(
          scrollController: scrollController,
          headerBuilder: () => [
            SliverAppBar(
              titleSpacing: 0,
              toolbarHeight: kToolbarHeight * 1.9,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SearchBar(
                      enabled: false,
                      onTap: () => context
                          .read<SearchBloc>()
                          .add(const SearchGoBackToSearchOptionsRequested()),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context
                            .read<SearchBloc>()
                            .add(const SearchGoBackToSearchOptionsRequested()),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: const _SelectedTagList(),
                  ),
                ],
              ),
              floating: true,
              snap: true,
              automaticallyImplyLeading: false,
            ),
            const SliverToBoxAdapter(child: _Divider()),
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
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final tags = context.select((SearchBloc bloc) => bloc.state.selectedTags);

    return tags.isNotEmpty
        ? const Divider(height: 15, thickness: 1)
        : const SizedBox.shrink();
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.queryEditingController,
    this.focusNode,
  });

  final RichTextController queryEditingController;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
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
