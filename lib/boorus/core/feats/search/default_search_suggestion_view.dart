// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/utils.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/tags/tag_suggestion_items.dart';
import 'search_notifier.dart';
import 'suggestions_notifier.dart';
import 'tag_search_item.dart';

class DefaultSearchSuggestionView extends ConsumerWidget {
  const DefaultSearchSuggestionView({
    super.key,
    required this.tags,
    required this.textEditingController,
  });

  final List<TagSearchItem> tags;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return SafeArea(
      child: Column(
        children: [
          SelectedTagListWithData(
            tags: tags,
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
                    ref.read(searchProvider.notifier).tapTag(tag.value);
                  },
                  textColorBuilder: (tag) =>
                      generateAutocompleteTagColor(tag, theme),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
