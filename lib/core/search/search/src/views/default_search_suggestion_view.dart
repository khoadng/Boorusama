// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/ref.dart';
import '../../../selected_tags/selected_tag_controller.dart';
import '../../../suggestions/suggestions_notifier.dart';
import '../../../suggestions/tag_suggestion_items.dart';
import '../widgets/search_controller.dart';
import '../widgets/selected_tag_list_with_data.dart';

class DefaultSearchSuggestionView extends ConsumerWidget {
  const DefaultSearchSuggestionView({
    required this.textEditingController,
    required this.searchController,
    super.key,
    this.selectedTagController,
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
                  config: ref.watchConfigAuth,
                  tags: suggestionTags,
                  currentQuery: query.text,
                  onItemTap: (tag) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    searchController.tapTag(tag.value);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
