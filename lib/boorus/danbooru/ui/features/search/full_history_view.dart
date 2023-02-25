// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/search_bar.dart';

class FullHistoryView extends StatelessWidget {
  const FullHistoryView({
    super.key,
    required this.onHistoryTap,
    required this.onHistoryFiltered,
    required this.onHistoryRemoved,
    required this.histories,
    this.scrollController,
    this.useAppbar = true,
  });

  final ValueChanged<String> onHistoryTap;
  final ValueChanged<String> onHistoryFiltered;
  final void Function(SearchHistory item) onHistoryRemoved;
  final List<SearchHistory> histories;
  final bool useAppbar;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SearchBar(
            onChanged: onHistoryFiltered,
          ),
        ),
        Expanded(
          child: ImplicitlyAnimatedList<SearchHistory>(
            items: histories,
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
