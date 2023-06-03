// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/domain/searches.dart';
import 'package:boorusama/i18n.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({
    super.key,
    required this.onHistoryRemoved,
    required this.onHistoryTap,
    required this.onHistoryCleared,
    required this.onFullHistoryRequested,
    required this.histories,
  });

  final void Function(SearchHistory item) onHistoryRemoved;
  final void Function() onHistoryCleared;
  final void Function() onFullHistoryRequested;
  final ValueChanged<String> onHistoryTap;
  final List<SearchHistory> histories;

  @override
  Widget build(BuildContext context) {
    if (histories.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const Divider(
          thickness: 1,
          indent: 10,
          endIndent: 10,
        ),
        _HistoryHeader(
          onHistoryRemoved: onHistoryRemoved,
          onHistoryTap: onHistoryTap,
          onHistoryCleared: onHistoryCleared,
          onFullHistoryRequested: onFullHistoryRequested,
        ),
        ...histories.take(5).map(
              (item) => _HistoryTile(
                item: item,
                onHistoryTap: onHistoryTap,
              ),
            ),
      ],
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({
    required this.onHistoryRemoved,
    required this.onHistoryTap,
    required this.onHistoryCleared,
    required this.onFullHistoryRequested,
  });

  final void Function(SearchHistory item) onHistoryRemoved;
  final void Function() onHistoryCleared;
  final void Function() onFullHistoryRequested;
  final ValueChanged<String> onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'search.history.history'.tr().toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          IconButton(
            onPressed: onFullHistoryRequested,
            icon: const Icon(Icons.manage_history),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.onHistoryTap,
    required this.item,
  });

  final ValueChanged<String> onHistoryTap;
  final SearchHistory item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Text(item.query),
      contentPadding: const EdgeInsets.only(left: 16),
      onTap: () => onHistoryTap(item.query),
    );
  }
}
