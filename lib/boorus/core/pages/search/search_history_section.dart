// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'history_list.dart';

class SearchHistorySection extends StatelessWidget {
  const SearchHistorySection({
    super.key,
    required this.onHistoryTap,
    required this.onHistoryRemoved,
    required this.onHistoryCleared,
    required this.onFullHistoryRequested,
    required this.histories,
  });

  final ValueChanged<String> onHistoryTap;
  final void Function(SearchHistory item) onHistoryRemoved;
  final void Function() onHistoryCleared;
  final void Function() onFullHistoryRequested;
  final List<SearchHistory> histories;

  @override
  Widget build(BuildContext context) {
    return histories.isNotEmpty
        ? HistoryList(
            onHistoryRemoved: onHistoryRemoved,
            onHistoryTap: onHistoryTap,
            onHistoryCleared: onHistoryCleared,
            onFullHistoryRequested: onFullHistoryRequested,
            histories: histories,
          )
        : const SizedBox.shrink();
  }
}
