// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../foundation/display/media_query_utils.dart';
import '../../../../../foundation/platform.dart';
import '../../../selected_tags/types.dart';
import '../types/search_history.dart';

class SearchHistorySection extends StatelessWidget {
  const SearchHistorySection({
    required this.onHistoryTap,
    required this.histories,
    super.key,
    this.onFullHistoryRequested,
    this.maxHistory = 5,
    this.showTime = false,
    this.reverseScheme,
  });

  final ValueChanged<SearchHistory> onHistoryTap;
  final void Function()? onFullHistoryRequested;
  final List<SearchHistory> histories;
  final int maxHistory;
  final bool showTime;
  final bool? reverseScheme;

  @override
  Widget build(BuildContext context) {
    return histories.isNotEmpty
        ? RemoveLeftPaddingOnLargeScreen(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.t.search.history.history.toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (onFullHistoryRequested != null)
                        IconButton(
                          onPressed: onFullHistoryRequested,
                          icon: const Icon(Symbols.manage_history),
                        ),
                    ],
                  ),
                ),
                ...histories
                    .take(maxHistory)
                    .map(
                      (item) => ListTile(
                        visualDensity: VisualDensity.compact,
                        title: SearchHistoryQueryWidget(
                          history: item,
                          reverseScheme: reverseScheme,
                        ),
                        contentPadding: const EdgeInsets.only(left: 8),
                        onTap: () => onHistoryTap(item),
                        minTileHeight: isDesktopPlatform() ? 0 : null,
                        subtitle: showTime
                            ? DateTooltip(
                                date: item.createdAt,
                                child: Text(
                                  item.createdAt.fuzzify(
                                    locale: Localizations.localeOf(context),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}

class SearchHistoryQueryWidget extends StatelessWidget {
  const SearchHistoryQueryWidget({
    required this.history,
    super.key,
    this.reverseScheme,
  });

  final SearchHistory history;
  final bool? reverseScheme;

  @override
  Widget build(BuildContext context) {
    return switch (history.queryType) {
      QueryType.list => Wrap(
        spacing: 4,
        runSpacing: 4,
        children: history
            .queryAsList()
            .map(
              (e) => IgnorePointer(
                child: CompactChip(
                  label: e,
                  borderRadius: BorderRadius.circular(8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 8,
                  ),
                  backgroundColor: (reverseScheme ?? false)
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            )
            .toList(),
      ),
      _ => Text(history.query),
    };
  }
}
