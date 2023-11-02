// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';

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
      backgroundColor: context.theme.cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      width: min(context.screenWidth * 0.7, 600),
      height: min(context.screenHeight * 0.7, 500),
      builder: (context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              context.navigator.pop(),
        },
        child: Focus(
          autofocus: true,
          child: builder(context, false),
        ),
      ),
    );
  }
}

class SimpleTagSearchView extends ConsumerStatefulWidget {
  const SimpleTagSearchView({
    super.key,
    required this.onSelected,
    this.ensureValidTag = true,
    this.closeOnSelected = true,
    this.floatingActionButton,
    this.backButton,
    this.onSubmitted,
    this.textColorBuilder,
    this.emptyBuilder,
  });

  final void Function(AutocompleteData tag) onSelected;
  final bool ensureValidTag;
  final bool closeOnSelected;
  final Widget Function(String currentText)? floatingActionButton;
  final Widget? backButton;
  final void Function(BuildContext context, String text)? onSubmitted;
  final Color? Function(AutocompleteData tag)? textColorBuilder;
  final Widget Function()? emptyBuilder;

  @override
  ConsumerState<SimpleTagSearchView> createState() =>
      _SimpleTagSearchViewState();
}

class _SimpleTagSearchViewState extends ConsumerState<SimpleTagSearchView> {
  final textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;

    return ValueListenableBuilder(
      valueListenable: textEditingController,
      builder: (context, query, child) {
        final suggestionTags = ref.watch(suggestionProvider(query.text));
        final tags = widget.ensureValidTag
            ? suggestionTags.where((e) => e.category != null).toIList()
            : suggestionTags;

        return Scaffold(
          floatingActionButton: widget.floatingActionButton?.call(query.text),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: BooruSearchBar(
                  queryEditingController: textEditingController,
                  backgroundColor: context.colorScheme.background,
                  leading: widget.backButton,
                  autofocus: true,
                  onSubmitted: (text) =>
                      widget.onSubmitted?.call(context, text),
                  onChanged: (value) {
                    ref
                        .read(suggestionsProvider(config).notifier)
                        .getSuggestions(value);
                  },
                ),
              ),
              tags.isNotEmpty
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TagSuggestionItems(
                          textColorBuilder: widget.textColorBuilder,
                          backgroundColor: context.colorScheme.background,
                          tags: tags,
                          onItemTap: (tag) {
                            if (widget.closeOnSelected) {
                              context.navigator.pop();
                            }
                            widget.onSelected(tag);
                          },
                          currentQuery: query.text,
                        ),
                      ),
                    )
                  : Expanded(
                      child: widget.emptyBuilder != null
                          ? SingleChildScrollView(child: widget.emptyBuilder!())
                          : const Center(
                              child: SizedBox.shrink(),
                            ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
