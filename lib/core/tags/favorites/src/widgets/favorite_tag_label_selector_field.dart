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
    return Row(
      children: [
        Container(
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
              optionValueBuilder: (option) => option == kSpecialLabelKeyForAll
                  ? context.t.favorite_tags.labels.all
                  : option,
              value: selected == ''
                  ? context.t.favorite_tags.labels.all
                  : selected,
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
      ],
    );
  }
}
