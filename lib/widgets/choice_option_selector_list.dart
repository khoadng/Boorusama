// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

sealed class OptionSelectorItem {
  const OptionSelectorItem();
}

final class ButtonType extends OptionSelectorItem {
  const ButtonType();
}

final class OptionType extends OptionSelectorItem {
  const OptionType({
    required this.data,
  });

  final String data;
}

class ChoiceOptionSelectorList extends ConsumerStatefulWidget {
  const ChoiceOptionSelectorList({
    super.key,
    required this.options,
    required this.selectedOption,
    this.icon,
    this.onSelected,
    required this.sheetTitle,
  });

  final List<String> options;
  final String? selectedOption;
  final Widget? icon;
  final void Function(String?)? onSelected;
  final String sheetTitle;

  @override
  ConsumerState<ChoiceOptionSelectorList> createState() =>
      _ChoiceOptionSelectorListState();
}

class _ChoiceOptionSelectorListState
    extends ConsumerState<ChoiceOptionSelectorList> {
  final scrollController = AutoScrollController();
  late var selectedOption = widget.selectedOption;

  @override
  void didUpdateWidget(covariant ChoiceOptionSelectorList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedOption != widget.selectedOption) {
      selectedOption = widget.selectedOption;
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      const ButtonType(),
      null,
      ...widget.options.map((e) => OptionType(data: e)),
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
          final selected = switch (value) {
            ButtonType _ => false,
            OptionType o => o.data == selectedOption,
            null => selectedOption == null,
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
              OptionType o => AutoScrollTag(
                  controller: scrollController,
                  index: index,
                  key: ValueKey(index),
                  child: BooruChip(
                    borderRadius: BorderRadius.circular(8),
                    disabled: !selected,
                    color: selected
                        ? context.colorScheme.onSurface
                        : context.theme.hintColor,
                    onPressed: () => _onSelect(o.data, index),
                    label: Text(
                      o.data,
                      style: TextStyle(
                        color: selected ? null : context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ButtonType _ => IconButton(
                  onPressed: () {
                    final items = options.whereType<OptionType>().toList();
                    showBarModalBottomSheet(
                        context: context,
                        duration: const Duration(milliseconds: 200),
                        builder: (context) => OptionSearchableSheet(
                              title: widget.sheetTitle,
                              items: items,
                              scrollController:
                                  ModalScrollController.of(context),
                              onFilter: (query) => items.where((e) {
                                final value = e.data;

                                return value
                                    .toLowerCase()
                                    .contains(query.toLowerCase());
                              }).toList(),
                              itemBuilder: (context, option) => ListTile(
                                minVerticalPadding: 4,
                                title: Text(
                                  option.data,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  final valueIndex = options.indexOf(option);
                                  _onSelect(option.data, valueIndex);
                                },
                              ),
                            ));
                  },
                  icon: widget.icon ?? const Icon(Symbols.tune),
                ),
            },
          );
        },
      ),
    );
  }

  void _onSelect(String? value, int index) {
    widget.onSelected?.call(value);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.end,
        duration: const Duration(milliseconds: 300),
      );
    });
  }
}
