// Package imports:
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';

const kSpecialLabelKeyForAll = '____all____';

class FavoriteTagLabelSelectorField extends StatelessWidget {
  const FavoriteTagLabelSelectorField({
    required this.selected,
    required this.labels,
    required this.onSelect,
    super.key,
  });

  final String selected;
  final List<String> labels;
  final void Function(String value) onSelect;

  @override
  Widget build(BuildContext context) {
    // Read now: the sheet builds options after this field may be gone, as a
    // search popover closes once the sheet takes focus.
    final allLabel = context.t.favorite_tags.labels.all;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              maxWidth: 160,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: OptionSingleSearchableField(
                backgroundColor: Kurumi.themeOf(
                  context,
                ).colorScheme.surfaceContainerHigh,
                sheetTitle: context.t.favorite_tags.labels.title,
                optionValueBuilder: (option) =>
                    option == kSpecialLabelKeyForAll ? allLabel : option,
                value: selected == '' ? allLabel : selected,
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
          ),
        ),
      ],
    );
  }
}
