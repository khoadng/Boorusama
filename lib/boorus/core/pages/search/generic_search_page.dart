// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/feats/utils.dart';
import 'package:boorusama/boorus/core/pages/search/search_app_bar.dart';
import 'package:boorusama/boorus/core/pages/search/search_button.dart';
import 'package:boorusama/boorus/core/pages/search/search_divider.dart';
import 'package:boorusama/boorus/core/pages/search/search_landing_view.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/boorus/core/pages/search/tag_suggestion_items.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/flutter.dart';

class GenericSearchPage extends ConsumerStatefulWidget {
  const GenericSearchPage({
    super.key,
    this.patterns,
    required this.resultPageBuilder,
    this.optionsPageBuilder,
    this.initialQuery,
  });

  final Map<RegExp, TextStyle>? patterns;
  final String? initialQuery;
  final Widget Function(List<String> selectedTags) resultPageBuilder;
  final Widget Function()? optionsPageBuilder;

  @override
  ConsumerState<GenericSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<GenericSearchPage> {
  late final queryEditingController = RichTextController(
    patternMatchMap: widget.patterns ??
        {
          RegExp(''): const TextStyle(color: Colors.white),
        },
    // ignore: no-empty-block
    onMatch: (match) {},
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
    final theme = ref.watch(themeProvider);

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
      onTap: () => context.focusScope.unfocus(),
      child: Builder(
        builder: (context) => switch (displayState) {
          DisplayState.options => widget.optionsPageBuilder?.call() ??
              Scaffold(
                floatingActionButton: const SearchButton(),
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
                  child: SearchAppBar(
                    focusNode: focus,
                    queryEditingController: queryEditingController,
                  ),
                ),
                body: const SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SelectedTagListWithData(),
                        SearchDivider(),
                        SearchLandingView(),
                      ],
                    ),
                  ),
                ),
              ),
          DisplayState.suggestion => Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight * 1.2),
                child: SearchAppBar(
                  focusNode: focus,
                  queryEditingController: queryEditingController,
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    const SelectedTagListWithData(),
                    const SearchDivider(),
                    Expanded(
                      child: TagSuggestionItemsWithData(
                        textColorBuilder: (tag) =>
                            generateAutocompleteTagColor(tag, theme),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          DisplayState.result => widget.resultPageBuilder(
              ref.watch(selectedRawTagStringProvider),
            )
        },
      ),
    );
  }
}
