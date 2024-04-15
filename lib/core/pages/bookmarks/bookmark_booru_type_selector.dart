// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme_utils.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'providers.dart';

sealed class BooruSourceUrlSelectorItem {
  const BooruSourceUrlSelectorItem();
}

final class OptionButtonType extends BooruSourceUrlSelectorItem {
  const OptionButtonType();
}

final class OptionUrlType extends BooruSourceUrlSelectorItem {
  const OptionUrlType({
    required this.url,
  });

  final String url;
}

class BookmarkBooruSourceUrlSelector extends ConsumerStatefulWidget {
  const BookmarkBooruSourceUrlSelector({
    super.key,
  });

  @override
  ConsumerState<BookmarkBooruSourceUrlSelector> createState() =>
      _BookmarkBooruSourceUrlSelectorState();
}

class _BookmarkBooruSourceUrlSelectorState
    extends ConsumerState<BookmarkBooruSourceUrlSelector> {
  final scrollController = AutoScrollController();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      const OptionButtonType(),
      null,
      ...ref
          .watch(availableBooruUrlsProvider)
          .map((e) => OptionUrlType(url: e)),
    ];

    return Container(
      height: 56,
      color: context.colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final value = options[index];
          final selectedUrl = ref.watch(selectedBooruUrlProvider);
          final selected = switch (value) {
            OptionButtonType _ => false,
            OptionUrlType o => o.url == selectedUrl,
            null => selectedUrl == null,
          };

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: switch (value) {
              null => AutoScrollTag(
                  controller: scrollController,
                  index: index,
                  key: ValueKey(index),
                  child: BooruChip(
                    borderRadius: BorderRadius.circular(8),
                    disabled: !selected,
                    color: selected
                        ? context.colorScheme.onSurface
                        : context.theme.hintColor,
                    onPressed: () => _onSelect(null, index),
                    label: Text(
                      'All',
                      style: TextStyle(
                        color: selected ? null : context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              OptionUrlType o => AutoScrollTag(
                  controller: scrollController,
                  index: index,
                  key: ValueKey(index),
                  child: BooruChip(
                    borderRadius: BorderRadius.circular(8),
                    disabled: !selected,
                    color: selected
                        ? context.colorScheme.onSurface
                        : context.theme.hintColor,
                    onPressed: () => _onSelect(o.url, index),
                    label: Text(
                      o.url,
                      style: TextStyle(
                        color: selected ? null : context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              OptionButtonType _ => IconButton(
                  onPressed: () {
                    final items = options.whereType<OptionUrlType>().toList();
                    showBarModalBottomSheet(
                        context: context,
                        duration: const Duration(milliseconds: 200),
                        builder: (context) => OptionSearchableSheet(
                              title: 'Source',
                              items: items,
                              scrollController:
                                  ModalScrollController.of(context),
                              onFilter: (query) => items.where((e) {
                                final value = e.url;

                                return value
                                    .toLowerCase()
                                    .contains(query.toLowerCase());
                              }).toList(),
                              itemBuilder: (context, option) => ListTile(
                                minVerticalPadding: 4,
                                title: Text(
                                  option.url,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  final valueIndex = options.indexOf(option);
                                  _onSelect(option.url, valueIndex);
                                },
                              ),
                            ));
                  },
                  icon: const Icon(Symbols.tune),
                ),
            },
          );
        },
      ),
    );
  }

  void _onSelect(String? value, int index) {
    ref.read(selectedBooruUrlProvider.notifier).state = value;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.end,
        duration: const Duration(milliseconds: 300),
      );
    });
  }
}
