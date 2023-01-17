// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/search/search.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';
import 'package:boorusama/core/ui/search_bar.dart';

void showSimpleTagSearchView(
  BuildContext context, {
  bool ensureValidTag = false,
  Widget Function(String text)? floatingActionButton,
  required void Function(AutocompleteData tag) onSelected,
  void Function(BuildContext context, String text)? onSubmitted,
}) {
  if (isMobilePlatform()) {
    showBarModalBottomSheet(
      context: context,
      duration: const Duration(milliseconds: 200),
      builder: (context) => SimpleTagSearchView(
        onSubmitted: onSubmitted,
        ensureValidTag: ensureValidTag,
        floatingActionButton: floatingActionButton != null
            ? (text) => floatingActionButton.call(text)
            : null,
        onSelected: onSelected,
      ),
    );
  } else {
    showDesktopDialogWindow(
      context,
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
          child: SimpleTagSearchView(
            onSubmitted: onSubmitted,
            backButton: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            ensureValidTag: ensureValidTag,
            onSelected: onSelected,
          ),
        ),
      ),
    );
  }
}

class SimpleTagSearchView extends StatelessWidget {
  const SimpleTagSearchView({
    super.key,
    required this.onSelected,
    this.ensureValidTag = true,
    this.closeOnSelected = true,
    this.floatingActionButton,
    this.backButton,
    this.onSubmitted,
  });

  final void Function(AutocompleteData tag) onSelected;
  final bool ensureValidTag;
  final bool closeOnSelected;
  final Widget Function(String currentText)? floatingActionButton;
  final Widget? backButton;
  final void Function(BuildContext context, String text)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TagSearchBloc(
        autocompleteRepository: context.read<AutocompleteRepository>(),
        tagInfo: context.read<TagInfo>(),
      ),
      child: BlocBuilder<TagSearchBloc, TagSearchState>(
        builder: (context, state) {
          final tags = ensureValidTag
              ? state.suggestionTags.where((e) => e.category != null).toList()
              : state.suggestionTags;

          return Scaffold(
            backgroundColor: Theme.of(context).cardColor,
            floatingActionButton: floatingActionButton?.call(state.query),
            body: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: SearchBar(
                    backgroundColor: Theme.of(context).backgroundColor,
                    leading: backButton,
                    autofocus: true,
                    onSubmitted: (text) => onSubmitted?.call(context, text),
                    onChanged: (value) {
                      context
                          .read<TagSearchBloc>()
                          .add(TagSearchChanged(value));
                    },
                  ),
                ),
                if (tags.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TagSuggestionItems(
                        backgroundColor: Theme.of(context).backgroundColor,
                        tags: tags,
                        onItemTap: (tag) {
                          if (closeOnSelected) {
                            Navigator.of(context).pop();
                          }
                          onSelected(tag);
                        },
                        currentQuery: state.query,
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
