// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class SearchScope extends ConsumerStatefulWidget {
  const SearchScope({
    super.key,
    this.pattern,
    this.initialQuery,
    required this.builder,
  });

  final Map<RegExp, TextStyle>? pattern;
  final String? initialQuery;
  final Widget Function(
    DisplayState state,
    ThemeMode theme,
    FocusNode focus,
    RichTextController controller,
    SelectedTagController selectedTagController,
    SearchPageController notifier,
    bool allowSearch,
  ) builder;

  @override
  ConsumerState<SearchScope> createState() => _SearchScopeState();
}

class _SearchScopeState extends ConsumerState<SearchScope> {
  late final queryEditingController = RichTextController(
    patternMatchMap: widget.pattern ??
        {
          RegExp(''): const TextStyle(color: Colors.white),
        },
    onMatch: (match) {},
  );
  final focus = FocusNode();
  late final selectedTagController =
      SelectedTagController(tagInfo: ref.read(tagInfoProvider));

  late final searchController = SearchPageController(
    filterOperatorBuilder: () => getFilterOperator(queryEditingController.text),
    queryController: queryEditingController,
    searchHistory: ref.read(searchHistoryProvider.notifier),
    selectedTagController: selectedTagController,
    stateController: displayState,
  );

  final displayState = ValueNotifier(DisplayState.options);

  @override
  void initState() {
    super.initState();

    ref.read(searchHistoryProvider.notifier).fetchHistories();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null) {
        searchController.skipToResultWithTag(widget.initialQuery!);
      }
    });

    queryEditingController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    queryEditingController.removeListener(_onTextChanged);

    queryEditingController.dispose();
    selectedTagController.dispose();
    searchController.dispose();

    focus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = queryEditingController.text;
    final op = getFilterOperator(query);

    if (query.isEmpty) {
      if (displayState.value != DisplayState.result) {
        searchController.resetToOptions();
      }
    } else {
      searchController.goToSuggestions();
    }

    if ((sanitizeQuery(query)).length == 1 && op != FilterOperator.none) {
      return;
    }

    ref.read(suggestionsProvider.notifier).getSuggestions(sanitizeQuery(query));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.focusScope.unfocus(),
      child: Builder(
        builder: (context) {
          final theme = ref.watch(themeProvider);

          return ValueListenableBuilder(
            valueListenable: selectedTagController,
            builder: (context, tags, child) {
              return ValueListenableBuilder(
                valueListenable: displayState,
                builder: (context, state, child) {
                  return widget.builder(
                    state,
                    theme,
                    focus,
                    queryEditingController,
                    selectedTagController,
                    searchController,
                    allowSearch(state, tags),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  bool allowSearch(DisplayState state, List<TagSearchItem> tags) =>
      switch (state) {
        DisplayState.options => tags.isNotEmpty,
        _ => false,
      };
}
