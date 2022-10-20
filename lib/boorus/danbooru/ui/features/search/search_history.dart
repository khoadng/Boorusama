// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';

class SearchHistorySection extends StatelessWidget {
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
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  List<Widget> _buildHistories(
    BuildContext context,
    List<SearchHistory> histories,
  ) {
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
              'search.history.history'.tr().toUpperCase(),
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: () => ReadContext(context)
                  .read<SearchHistoryCubit>()
                  .clearHistory(),
              child: const Text('search.history.clear').tr(),
            ),
          ],
        ),
      );
      widgets
        ..insert(0, header)
        ..insert(
          0,
          const Divider(
            thickness: 1,
            indent: 10,
            endIndent: 10,
          ),
        );
    }

    return widgets;
  }
}
