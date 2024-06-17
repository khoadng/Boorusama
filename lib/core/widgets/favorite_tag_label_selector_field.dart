// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

const kSpecialLabelKeyForAll = '____all____';

class FavoriteTagLabelSelectorField extends StatelessWidget {
  const FavoriteTagLabelSelectorField({
    super.key,
    required this.selected,
    required this.labels,
    required this.onSelect,
  });

  final String selected;
  final List<String> labels;
  final void Function(String value) onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            maxWidth: 160,
          ),
          child: OptionSingleSearchableField(
            backgroundColor: context.colorScheme.surface,
            sheetTitle: 'Select',
            optionValueBuilder: (option) =>
                option == kSpecialLabelKeyForAll ? '<All>' : option,
            value: selected == '' ? '<All>' : selected,
            items: [
              kSpecialLabelKeyForAll,
              ...labels,
            ],
            onSelect: (value) {
              if (value == null) return;
              final v = value == kSpecialLabelKeyForAll ? '' : value;
              onSelect(v);
            },
          ),
        ),
      ],
    );
  }
}
