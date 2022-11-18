import 'package:boorusama/boorus/danbooru/application/search/search_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        context.select((SearchHistoryCubit cubit) => cubit.state.data);

    if (histories == null || histories.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const _HistoryHeader(),
        const Divider(
          thickness: 1,
          indent: 10,
          endIndent: 10,
        ),
        ...histories.map(
          (item) => _HistoryTile(
            item: item,
            onHistoryRemoved: onHistoryRemoved,
            onHistoryTap: onHistoryTap,
          ),
        ),
      ],
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

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
          TextButton(
            onPressed: () =>
                context.read<SearchBloc>().add(const SearchHistoryCleared()),
            child: const Text('search.history.clear').tr(),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.onHistoryRemoved,
    required this.onHistoryTap,
    required this.item,
  });

  final void Function(SearchHistory item) onHistoryRemoved;
  final ValueChanged<String> onHistoryTap;
  final SearchHistory item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Text(item.query),
      contentPadding: const EdgeInsets.only(left: 16),
      trailing: IconButton(
        onPressed: () => onHistoryRemoved(item),
        icon: const Icon(Icons.close),
      ),
      onTap: () => onHistoryTap(item.query),
    );
  }
}
