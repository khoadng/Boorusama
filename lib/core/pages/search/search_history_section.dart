// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/time.dart';

class SearchHistorySection extends StatelessWidget {
  const SearchHistorySection({
    super.key,
    required this.onHistoryTap,
    this.onFullHistoryRequested,
    required this.histories,
    this.maxHistory = 5,
    this.showTime = false,
  });

  final ValueChanged<String> onHistoryTap;
  final void Function()? onFullHistoryRequested;
  final List<SearchHistory> histories;
  final int maxHistory;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    return histories.isNotEmpty
        ? Column(
            children: [
              const Divider(
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'search.history.history'.tr().toUpperCase(),
                      style: context.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (onFullHistoryRequested != null)
                      IconButton(
                        onPressed: onFullHistoryRequested,
                        icon: const Icon(Icons.manage_history),
                      ),
                  ],
                ),
              ),
              ...histories.take(maxHistory).map(
                    (item) => ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text(item.query),
                      contentPadding: const EdgeInsets.only(left: 16),
                      onTap: () => onHistoryTap(item.query),
                      subtitle: showTime
                          ? Text(
                              item.createdAt.fuzzify(
                                  locale: Localizations.localeOf(context)),
                            )
                          : null,
                    ),
                  ),
            ],
          )
        : const SizedBox.shrink();
  }
}
