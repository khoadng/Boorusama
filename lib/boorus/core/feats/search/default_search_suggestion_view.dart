// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/utils.dart';
import 'package:boorusama/boorus/core/pages/search/selected_tag_list_with_data.dart';
import 'package:boorusama/boorus/core/pages/search/tag_suggestion_items.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'tag_search_item.dart';

class DefaultSearchSuggestionView extends ConsumerWidget {
  const DefaultSearchSuggestionView({
    super.key,
    required this.tags,
  });

  final List<TagSearchItem> tags;

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
            child: TagSuggestionItemsWithData(
              textColorBuilder: (tag) =>
                  generateAutocompleteTagColor(tag, theme),
            ),
          ),
        ],
      ),
    );
  }
}