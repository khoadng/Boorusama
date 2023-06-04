// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feat/search/suggestions_notifier.dart';
import 'package:boorusama/boorus/core/pages/search_bar.dart';
import 'package:boorusama/boorus/core/pages/tag_suggestion_items.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/foundation/platform.dart';

void showSimpleTagSearchView(
  BuildContext context, {
  bool ensureValidTag = false,
  Widget Function(String text)? floatingActionButton,
  RouteSettings? settings,
  required Widget Function(BuildContext context, bool isMobile) builder,
}) {
  if (isMobilePlatform()) {
    showBarModalBottomSheet(
      context: context,
      settings: settings,
      duration: const Duration(milliseconds: 200),
      builder: (context) => builder(context, true),
    );
  } else {
    showDesktopDialogWindow(
      context,
      settings: settings,
      backgroundColor: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      width: min(MediaQuery.of(context).size.width * 0.7, 600),
      height: min(MediaQuery.of(context).size.height * 0.7, 500),
      builder: (context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.of(context).pop(),
        },
        child: Focus(
          autofocus: true,
          child: builder(context, false),
        ),
      ),
    );
  }
}

final _queryProvider = StateProvider.autoDispose<String>((ref) => "");

class SimpleTagSearchView extends ConsumerWidget {
  const SimpleTagSearchView({
    super.key,
    required this.onSelected,
    this.ensureValidTag = true,
    this.closeOnSelected = true,
    this.floatingActionButton,
    this.backButton,
    this.onSubmitted,
    this.textColorBuilder,
  });

  final void Function(AutocompleteData tag) onSelected;
  final bool ensureValidTag;
  final bool closeOnSelected;
  final Widget Function(String currentText)? floatingActionButton;
  final Widget? backButton;
  final void Function(BuildContext context, String text)? onSubmitted;
  final Color? Function(AutocompleteData tag)? textColorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionTags = ref.watch(suggestionsQuickSearchProvider);
    final query = ref.watch(_queryProvider);
    final tags = ensureValidTag
        ? suggestionTags.where((e) => e.category != null).toList()
        : suggestionTags;

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      floatingActionButton: floatingActionButton?.call(query),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: BooruSearchBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              leading: backButton,
              autofocus: true,
              onSubmitted: (text) => onSubmitted?.call(context, text),
              onChanged: (value) {
                ref.read(_queryProvider.notifier).state = value;
                ref
                    .read(suggestionsQuickSearchProvider.notifier)
                    .getSuggestions(value);
              },
            ),
          ),
          tags.isNotEmpty
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TagSuggestionItems(
                      textColorBuilder: textColorBuilder,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      tags: tags,
                      onItemTap: (tag) {
                        if (closeOnSelected) {
                          Navigator.of(context).pop();
                        }
                        onSelected(tag);
                      },
                      currentQuery: query,
                    ),
                  ),
                )
              : const Expanded(
                  child: Center(
                    child: SizedBox.shrink(),
                  ),
                ),
        ],
      ),
    );
  }
}
