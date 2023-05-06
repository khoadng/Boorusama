// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/search/search_notifier.dart';
import 'package:boorusama/core/application/search/search_provider.dart';
import 'package:boorusama/core/application/search/suggestions_notifier.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
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
    // final histories = context
    //     .select((SearchHistorySuggestionsBloc bloc) => bloc.state.histories);

    return SliverTagSuggestionItemsWithHistory(
      tags: suggestionTags,
      histories: const [], //FIXME: histories,
      currentQuery: currentQuery,
      onHistoryDeleted: (history) {
        ref.read(searchProvider.notifier).removeHistory(history.searchHistory);
      },
      onHistoryTap: (history) {
        FocusManager.instance.primaryFocus?.unfocus();
        ref.read(searchProvider.notifier).tapTag(history.tag);
      },
      onItemTap: (tag) {
        FocusManager.instance.primaryFocus?.unfocus();
        ref.read(searchProvider.notifier).tapTag(tag.value);
      },
      textColorBuilder: textColorBuilder,
    );
  }
}
