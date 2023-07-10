// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/flutter.dart';

typedef HiddenData = ({
  String name,
  int count,
  bool active,
});

class HiddenPostHeader extends StatelessWidget {
  const HiddenPostHeader({
    super.key,
    required this.tags,
    required this.onChanged,
    required this.hiddenCount,
  });

  final List<HiddenData> tags;
  final void Function(String tag, bool value) onChanged;
  final int hiddenCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: ListTileTheme.of(context).copyWith(
            visualDensity: const ShrinkVisualDensity(),
          ),
        ),
        child: ExpansionTile(
          title: Row(children: [
            const Text('Hidden'),
            const SizedBox(width: 4),
            Chip(
                padding: EdgeInsets.zero,
                visualDensity: const ShrinkVisualDensity(),
                backgroundColor: context.colorScheme.primary,
                label: Text(
                  hiddenCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ]),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Wrap(
                spacing: 8,
                children: tags
                    .map((e) => Badge(
                          backgroundColor: context.colorScheme.primary,
                          label: Text(
                            e.count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: ChoiceChip(
                            visualDensity: const ShrinkVisualDensity(),
                            selected: e.active,
                            backgroundColor:
                                context.theme.scaffoldBackgroundColor,
                            label: Text(e.name.replaceAll('_', ' ')),
                            onSelected: (value) {
                              onChanged(e.name, value);
                            },
                          ),
                        ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
