// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/local/repositories/search_history_repository.dart';

final _historyProvider =
    FutureProvider.autoDispose<List<SearchHistory>>((ref) async {
  final repo = ref.watch(searchHistoryProvider);
  final searchHistories = await repo.getHistories();

  searchHistories.sort((a, b) {
    return b.createdAt.compareTo(a.createdAt);
  });

  return searchHistories.take(5).toList();
});

class SearchHistorySection extends HookWidget {
  const SearchHistorySection({
    Key key,
    @required this.onHistoryTap,
  }) : super(key: key);

  final ValueChanged<String> onHistoryTap;

  @override
  Widget build(BuildContext context) {
    final searchHistories = useProvider(_historyProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...searchHistories.maybeWhen(
          data: (histories) {
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
            widgets..addAll(historyTiles);

            if (historyTiles.isNotEmpty) {
              final header = Padding(
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "History".toUpperCase(),
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context)
                                .appBarTheme
                                .actionsIconTheme
                                .color,
                          ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await context.read(searchHistoryProvider).clearAll();
                        context.refresh(_historyProvider);
                      },
                      child: Text("Clear"),
                    ),
                  ],
                ),
              );
              widgets.insert(0, header);
              widgets.insert(
                  0,
                  Divider(
                    indent: 10,
                    endIndent: 10,
                  ));
            }

            return widgets;
          },
          orElse: () => [SizedBox.shrink()],
        ),
      ],
    );
  }
}
