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
          title: Row(
            children: [
              const Text('Hidden'),
              const SizedBox(width: 8),
              Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: context.colorScheme.error),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      hiddenCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
            ],
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              children: tags
                  .map((e) => ChoiceChip(
                        selected: e.active,
                        label:
                            Text('${e.name.replaceAll('_', ' ')} (${e.count})'),
                        onSelected: (value) {
                          onChanged(e.name, value);
                        },
                      ))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
