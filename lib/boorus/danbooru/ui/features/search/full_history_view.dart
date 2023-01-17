import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'package:flutter/material.dart';

class FullHistoryView extends StatelessWidget {
  const FullHistoryView({
    super.key,
    required this.onHistoryTap,
    required this.onHistoryRemoved,
    required this.histories,
    this.useAppbar = true,
  });

  final ValueChanged<String> onHistoryTap;
  final void Function(SearchHistory item) onHistoryRemoved;
  final List<SearchHistory> histories;
  final bool useAppbar;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: histories.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(histories[index].query),
        onTap: () {
          onHistoryTap(histories[index].query);
        },
        trailing: IconButton(
          onPressed: () => onHistoryRemoved(histories[index]),
          icon: Icon(
            Icons.close,
            color: Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }
}
