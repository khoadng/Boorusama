// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/time.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../search_history.dart';

class SearchHistorySection extends StatelessWidget {
  const SearchHistorySection({
    super.key,
    required this.onHistoryTap,
    this.onFullHistoryRequested,
    required this.histories,
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
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'search.history.history'.tr().toUpperCase(),
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!Screen.of(context).size.isLarge)
                      if (onFullHistoryRequested != null)
                        IconButton(
                          onPressed: onFullHistoryRequested,
                          icon: const Icon(Symbols.manage_history),
                        ),
                  ],
                ),
              ),
              ...histories.take(maxHistory).map(
                    (item) => ListTile(
                      visualDensity: VisualDensity.compact,
                      title: SearchHistoryQueryWidget(
                        history: item,
                        reverseScheme: reverseScheme,
                      ),
                      contentPadding: const EdgeInsets.only(left: 12),
                      onTap: () => onHistoryTap(item),
                      minTileHeight: isDesktopPlatform() ? 0 : null,
                      subtitle: showTime
                          ? DateTooltip(
                              date: item.createdAt,
                              child: Text(
                                item.createdAt.fuzzify(
                                    locale: Localizations.localeOf(context)),
                              ),
                            )
                          : null,
                    ),
                  ),
            ],
          )
        : const SizedBox.shrink();
  }
}

class SearchHistoryQueryWidget extends StatelessWidget {
  const SearchHistoryQueryWidget({
    super.key,
    required this.history,
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
                    backgroundColor: reverseScheme == true
                        ? context.colorScheme.surface
                        : context.colorScheme.surfaceContainerHighest,
                  ),
                ),
              )
              .toList(),
        ),
      _ => Text(history.query),
    };
  }
}
