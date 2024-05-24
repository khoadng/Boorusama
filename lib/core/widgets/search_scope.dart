// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';

class SearchScope extends ConsumerStatefulWidget {
  const SearchScope({
    super.key,
    this.pattern,
    this.initialQuery,
    required this.builder,
    this.selectedTagController,
  });

  final Map<RegExp, TextStyle>? pattern;
  final SelectedTagController? selectedTagController;
  final String? initialQuery;
  final Widget Function(
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
  late final selectedTagController = widget.selectedTagController ??
      SelectedTagController(tagInfo: ref.read(tagInfoProvider));

  late final searchController = SearchPageController(
    textEditingController: queryEditingController,
    searchHistory: ref.read(searchHistoryProvider.notifier),
    selectedTagController: selectedTagController,
    suggestions: ref.read(suggestionsProvider(ref.readConfig).notifier),
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null) {
        searchController.skipToResultWithTag(widget.initialQuery!);
      }
    });
  }

  @override
  void dispose() {
    queryEditingController.dispose();
    if (widget.selectedTagController == null) {
      selectedTagController.dispose();
    }

    searchController.dispose();

    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: GestureDetector(
        onTap: () => context.focusScope.unfocus(),
        child: Builder(
          builder: (context) {
            return ValueListenableBuilder(
              valueListenable: selectedTagController,
              builder: (context, tags, child) {
                return widget.builder(
                  focus,
                  queryEditingController,
                  selectedTagController,
                  searchController,
                  allowSearch(tags),
                );
              },
            );
          },
        ),
      ),
    );
  }

  bool allowSearch(List<TagSearchItem> tags) => tags.isNotEmpty;
}
