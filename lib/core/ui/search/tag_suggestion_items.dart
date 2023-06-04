// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/ui/tag_suggestion_items.dart';

class TagSuggestionItemsWithData extends ConsumerWidget {
  const TagSuggestionItemsWithData({
    super.key,
    required this.textColorBuilder,
  });
  final Color? Function(AutocompleteData tag)? textColorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentQuery = ref.watch(searchQueryProvider);
    final suggestionTags = ref.watch(suggestionsProvider);

    return TagSuggestionItems(
      tags: suggestionTags,
      currentQuery: currentQuery,
      onItemTap: (tag) {
        FocusManager.instance.primaryFocus?.unfocus();
        ref.read(searchProvider.notifier).tapTag(tag.value);
      },
      textColorBuilder: textColorBuilder,
    );
  }
}
