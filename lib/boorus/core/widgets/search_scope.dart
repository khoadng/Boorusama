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
    SearchNotifier notifier,
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

  @override
  void initState() {
    super.initState();

    ref.read(searchHistoryProvider.notifier).fetchHistories();

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
    selectedTagController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      sanitizedQueryProvider,
      (prev, curr) {
        if (prev != curr) {
          final displayState = ref.read(displayStateProvider);
          if (curr.isEmpty && displayState != DisplayState.result) {
            queryEditingController.clear();
          }
        }
      },
    );

    ref.listen(
      sanitizedQueryProvider,
      (previous, next) {
        if (previous != next) {
          ref.read(suggestionsProvider.notifier).getSuggestions(next);
        }
      },
    );

    ref.listen(
      sanitizedQueryProvider,
      (prev, curr) {
        if (prev != curr) {
          if (curr.isEmpty) {
            if (ref.read(displayStateProvider) != DisplayState.result) {
              ref.read(searchProvider.notifier).resetToOptions();
            }
          } else {
            ref.read(searchProvider.notifier).goToSuggestions();
          }
        }
      },
    );

    return GestureDetector(
      onTap: () => context.focusScope.unfocus(),
      child: Builder(
        builder: (context) {
          final displayState = ref.watch(displayStateProvider);
          final theme = ref.watch(themeProvider);
          final notifier = ref.watch(searchProvider.notifier);

          return widget.builder(
            displayState,
            theme,
            focus,
            queryEditingController,
            selectedTagController,
            notifier,
            allowSearch(ref),
          );
        },
      ),
    );
  }

  bool allowSearch(WidgetRef ref) {
    final displayState = ref.watch(displayStateProvider);
    final selectedTags = ref.watch(selectedTagsProvider);

    if (displayState == DisplayState.options) {
      return selectedTags.isNotEmpty;
    }
    if (displayState == DisplayState.suggestion) return false;

    return false;
  }
}
