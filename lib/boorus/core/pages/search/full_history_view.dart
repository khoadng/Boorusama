// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';

class FullHistoryView extends ConsumerWidget {
  const FullHistoryView({
    super.key,
    required this.onHistoryTap,
    required this.onHistoryRemoved,
    this.scrollController,
    this.useAppbar = true,
  });

  final ValueChanged<String> onHistoryTap;
  final void Function(SearchHistory item) onHistoryRemoved;
  final bool useAppbar;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(searchHistoryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: BooruSearchBar(
            onChanged: (value) =>
                ref.read(searchHistoryProvider.notifier).filterHistories(value),
          ),
        ),
        Expanded(
          child: ImplicitlyAnimatedList<SearchHistory>(
            items: histories.filteredHistories,
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
                subtitle: Text(history.createdAt
                    .fuzzify(locale: Localizations.localeOf(context))),
                onTap: () {
                  onHistoryTap(history.query);
                },
                trailing: IconButton(
                  onPressed: () => onHistoryRemoved(history),
                  icon: Icon(
                    Icons.close,
                    color: context.theme.hintColor,
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
