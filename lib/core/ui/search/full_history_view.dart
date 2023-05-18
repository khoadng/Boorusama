// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/search.dart';
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/core/utils.dart';

class FullHistoryView extends ConsumerWidget {
  const FullHistoryView({
    super.key,
    required this.onHistoryTap,
    required this.onHistoryRemoved,
    this.scrollController,
    this.useAppbar = true,
  });

  final ValueChanged<String> onHistoryTap;
  final void Function(SearchHistory item) onHistoryRemoved;
  final bool useAppbar;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(searchHistoryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SearchBar(
            onChanged: (value) =>
                ref.read(searchHistoryProvider.notifier).filterHistories(value),
          ),
        ),
        Expanded(
          child: ImplicitlyAnimatedList<SearchHistory>(
            items: histories.filteredHistories,
            controller: scrollController,
            areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
            insertDuration: const Duration(milliseconds: 250),
            removeDuration: const Duration(milliseconds: 250),
            itemBuilder: (context, animation, history, index) =>
                SizeFadeTransition(
              sizeFraction: 0.7,
              curve: Curves.easeInOut,
              animation: animation,
              child: ListTile(
                title: Text(history.query),
                subtitle: Text(dateTimeToStringTimeAgo(history.createdAt)),
                onTap: () {
                  onHistoryTap(history.query);
                },
                trailing: IconButton(
                  onPressed: () => onHistoryRemoved(history),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
