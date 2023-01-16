// Flutter imports:
import 'package:boorusama/core/ui/widgets/conditional_render_widget.dart';
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/search/landing/landing_view.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/domain/tags/metatag.dart';
import 'package:boorusama/core/ui/search_bar.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'result/result_view.dart';
import 'selected_tag_list.dart';

import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart'
    hide SearchHistoryCleared;

class SearchPageDesktop extends StatefulWidget {
  const SearchPageDesktop({
    super.key,
    required this.metatags,
    required this.metatagHighlightColor,
  });

  final List<Metatag> metatags;
  final Color metatagHighlightColor;

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
      body: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  shadowColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  toolbarHeight: kToolbarHeight * 1.2,
                  title: SearchBar(
                    autofocus: true,
                    focus: focus,
                    queryEditingController: queryEditingController,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => AppRouter.router.pop(context),
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
          const VerticalDivider(width: 10),
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
      onHistoryCleared: () {
        context.read<SearchBloc>().add(const SearchHistoryCleared());
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
  const _Divider({
    // ignore: unused_element
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
