// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/search/selected_tag_controller.dart';
import 'package:boorusama/core/search/ui/selected_tag_list_with_data.dart';
import 'package:boorusama/core/search/ui/tag_suggestion_items.dart';
import 'search_controller.dart';
import 'suggestions_notifier.dart';

class DefaultSearchSuggestionView extends ConsumerWidget {
  const DefaultSearchSuggestionView({
    super.key,
    required this.textEditingController,
    this.selectedTagController,
    required this.searchController,
  });

  final TextEditingController textEditingController;
  final SelectedTagController? selectedTagController;
  final SearchPageController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          if (selectedTagController != null)
            SelectedTagListWithData(
              controller: selectedTagController!,
            ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: textEditingController,
              builder: (context, query, child) {
                final suggestionTags =
                    ref.watch(suggestionProvider(query.text));

                return TagSuggestionItems(
                  tags: suggestionTags,
                  currentQuery: query.text,
                  onItemTap: (tag) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    searchController.tapTag(tag.value);
                  },
                  textColorBuilder: (tag) =>
                      generateAutocompleteTagColor(ref, context, tag),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
