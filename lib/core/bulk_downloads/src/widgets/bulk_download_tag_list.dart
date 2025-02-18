// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../foundation/platform.dart';
import '../../../search/histories/history.dart';
import '../../../search/histories/providers.dart';
import '../../../search/histories/widgets.dart';
import '../../../search/search/routes.dart';
import '../../../search/selected_tags/tag.dart';

class BulkDownloadTagList extends ConsumerWidget {
  const BulkDownloadTagList({
    required this.tags,
    required this.onSubmit,
    required this.onRemove,
    required this.onHistoryTap,
    super.key,
  });

  final void Function(String tag) onSubmit;
  final void Function(String tag) onRemove;
  final void Function(SearchHistory history) onHistoryTap;
  final SearchTagSet tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Wrap(
        runAlignment: WrapAlignment.center,
        spacing: 5,
        runSpacing: isMobilePlatform() ? -4 : 8,
        children: [
          ...tags.list.map(
            (e) => Chip(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              label: Text(e.replaceAll('_', ' ')),
              deleteIcon: Icon(
                Symbols.close,
                size: 16,
                color: Theme.of(context).colorScheme.error,
              ),
              onDeleted: () => onRemove(e),
            ),
          ),
          IconButton(
            iconSize: 28,
            splashRadius: 20,
            onPressed: () {
              goToQuickSearchPage(
                context,
                ref: ref,
                emptyBuilder: (controller) => ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (_, value, __) => value.text.isEmpty
                      ? ref.watch(searchHistoryProvider).maybeWhen(
                            data: (data) => SearchHistorySection(
                              maxHistory: 20,
                              showTime: true,
                              histories: data.histories,
                              onHistoryTap: (history) {
                                Navigator.of(context).pop();
                                onHistoryTap(history);
                              },
                            ),
                            orElse: () => const SizedBox.shrink(),
                          )
                      : const SizedBox.shrink(),
                ),
                onSubmitted: (context, text, _) {
                  Navigator.of(context).pop();
                  onSubmit(text);
                },
                onSelected: (tag, _) {
                  onSubmit(tag);
                },
              );
            },
            icon: const Icon(Symbols.add),
          ),
        ],
      ),
    );
  }
}
