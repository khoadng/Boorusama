// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';

class SearchHistorySection extends HookWidget {
  const SearchHistorySection({
    Key? key,
    required this.onHistoryTap,
  }) : super(key: key);

  final ValueChanged<String> onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchHistoryCubit, AsyncLoadState<List<SearchHistory>>>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.status == LoadStatus.success)
            ..._buildHistories(context, state.data!)
          else
            const SizedBox.shrink()
        ],
      ),
    );
  }

  List<Widget> _buildHistories(
      BuildContext context, List<SearchHistory> histories) {
    final widgets = <Widget>[];

    final historyTiles = histories
        .map(
          (item) => ListTile(
            visualDensity: VisualDensity.compact,
            title: Text(item.query),
            onTap: () => onHistoryTap(item.query),
          ),
        )
        .toList();
    widgets.addAll(historyTiles);

    if (historyTiles.isNotEmpty) {
      final header = Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'History'.toUpperCase(),
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: () => ReadContext(context)
                  .read<SearchHistoryCubit>()
                  .clearHistory(),
              child: const Text('Clear'),
            ),
          ],
        ),
      );
      widgets
        ..insert(0, header)
        ..insert(
            0,
            const Divider(
              indent: 10,
              endIndent: 10,
            ));
    }

    return widgets;
  }
}
