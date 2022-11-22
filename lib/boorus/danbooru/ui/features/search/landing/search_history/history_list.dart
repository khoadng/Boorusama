// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/search_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';

import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart'
    show SearchHistoryBloc, SearchHistoryState;

class HistoryList extends StatelessWidget {
  const HistoryList({
    super.key,
    required this.onHistoryRemoved,
    required this.onHistoryTap,
  });

  final void Function(SearchHistory item) onHistoryRemoved;
  final ValueChanged<String> onHistoryTap;

  @override
  Widget build(BuildContext context) {
    final histories =
        context.select((SearchHistoryBloc bloc) => bloc.state.histories);

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
  });

  final void Function(SearchHistory item) onHistoryRemoved;
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
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          IconButton(
            onPressed: () {
              final bloc = context.read<SearchHistoryBloc>();
              showMaterialModalBottomSheet(
                context: context,
                duration: const Duration(milliseconds: 200),
                builder: (context) =>
                    BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
                  bloc: bloc,
                  builder: (context, state) {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('search.history.history').tr(),
                        actions: [
                          TextButton(
                            onPressed: () => context
                                .read<SearchBloc>()
                                .add(const SearchHistoryCleared()),
                            child: const Text('search.history.clear').tr(),
                          ),
                        ],
                      ),
                      body: ListView.builder(
                        itemCount: state.histories.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(state.histories[index].query),
                          onTap: () {
                            Navigator.of(context).pop();

                            onHistoryTap(state.histories[index].query);
                          },
                          trailing: IconButton(
                            onPressed: () =>
                                onHistoryRemoved(state.histories[index]),
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
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
