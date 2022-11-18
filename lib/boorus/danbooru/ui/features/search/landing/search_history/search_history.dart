// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/search_history/search_history.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'history_list.dart';

class SearchHistorySection extends StatelessWidget {
  const SearchHistorySection({
    super.key,
    required this.onHistoryTap,
    required this.onHistoryRemoved,
  });

  final ValueChanged<String> onHistoryTap;
  final void Function(SearchHistory item) onHistoryRemoved;

  @override
  Widget build(BuildContext context) {
    final status =
        context.select((SearchHistoryCubit cubit) => cubit.state.status);

    return status == LoadStatus.success
        ? HistoryList(
            onHistoryRemoved: onHistoryRemoved,
            onHistoryTap: onHistoryTap,
          )
        : const SizedBox.shrink();
  }
}
