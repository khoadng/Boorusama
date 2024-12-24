// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/widgets/widgets.dart';
import '../../../../foundation/display.dart';
import '../../../../theme.dart';
import '../../../search/widgets.dart';
import '../providers.dart';
import '../search_history.dart';
import 'search_history_section.dart';

class FullHistoryView extends ConsumerWidget {
  const FullHistoryView({
    required this.onHistoryTap,
    required this.onHistoryRemoved,
    super.key,
    this.scrollController,
    this.useAppbar = true,
  });

  final ValueChanged<SearchHistory> onHistoryTap;
  final void Function(SearchHistory item) onHistoryRemoved;
  final bool useAppbar;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: BooruSearchBar(
            onChanged: (value) =>
                ref.read(searchHistoryProvider.notifier).filterHistories(value),
          ),
        ),
        ref.watch(searchHistoryProvider).maybeWhen(
              data: (histories) => Expanded(
                child: ImplicitlyAnimatedList(
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
                      key: ValueKey(history.query),
                      title: SearchHistoryQueryWidget(history: history),
                      subtitle: DateTooltip(
                        date: history.createdAt,
                        child: Text(
                          history.createdAt
                              .fuzzify(locale: Localizations.localeOf(context)),
                        ),
                      ),
                      onTap: () {
                        onHistoryTap(history);
                      },
                      contentPadding: kPreferredLayout.isDesktop
                          ? const EdgeInsets.symmetric(
                              horizontal: 12,
                            )
                          : null,
                      minTileHeight: kPreferredLayout.isDesktop ? 0 : null,
                      trailing: IconButton(
                        onPressed: () => onHistoryRemoved(history),
                        icon: Icon(
                          Symbols.close,
                          color: Theme.of(context).colorScheme.hintColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
      ],
    );
  }
}
