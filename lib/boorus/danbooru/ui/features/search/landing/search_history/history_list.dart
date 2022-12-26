// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';

import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart'
    show SearchHistoryBloc, SearchHistoryState;

class HistoryList extends StatelessWidget {
  const HistoryList({
    super.key,
    required this.onHistoryRemoved,
    required this.onHistoryTap,
    required this.onHistoryCleared,
  });

  final void Function(SearchHistory item) onHistoryRemoved;
  final void Function() onHistoryCleared;
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
          onHistoryCleared: onHistoryCleared,
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
  });

  final void Function(SearchHistory item) onHistoryRemoved;
  final void Function() onHistoryCleared;
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
                    return _HistoryList(
                      onHistoryTap: onHistoryTap,
                      onHistoryRemoved: onHistoryRemoved,
                      onHistoryCleared: onHistoryCleared,
                      histories: state.histories,
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

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.onHistoryTap,
    required this.onHistoryRemoved,
    required this.onHistoryCleared,
    required this.histories,
  });

  final ValueChanged<String> onHistoryTap;
  final void Function(SearchHistory item) onHistoryRemoved;
  final void Function() onHistoryCleared;
  final List<SearchHistory> histories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('search.history.history').tr(),
        actions: [
          TextButton(
            onPressed: onHistoryCleared,
            child: const Text('search.history.clear').tr(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: histories.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(histories[index].query),
          onTap: () {
            Navigator.of(context).pop();

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
