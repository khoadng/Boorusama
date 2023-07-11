// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/flutter.dart';

typedef HiddenData = ({
  String name,
  int count,
  bool active,
});

class HiddenPostHeader extends StatefulWidget {
  const HiddenPostHeader({
    super.key,
    required this.tags,
    required this.onChanged,
    required this.hiddenCount,
    required this.onClosed,
  });

  final List<HiddenData> tags;
  final void Function(String tag, bool value) onChanged;
  final VoidCallback onClosed;
  final int hiddenCount;

  @override
  State<HiddenPostHeader> createState() => _HiddenPostHeaderState();
}

class _HiddenPostHeaderState extends State<HiddenPostHeader> {
  final expand = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          listTileTheme: ListTileTheme.of(context).copyWith(
            contentPadding: const EdgeInsets.only(left: 8),
            horizontalTitleGap: 0,
            visualDensity: const ShrinkVisualDensity(),
          ),
        ),
        child: ExpansionTile(
          controlAffinity: ListTileControlAffinity.leading,
          trailing: ValueListenableBuilder<bool>(
            valueListenable: expand,
            builder: (context, expanded, child) {
              return expanded
                  ? IconButton(
                      onPressed: widget.onClosed,
                      icon: const Icon(Icons.close),
                    )
                  : const SizedBox.shrink();
            },
          ),
          onExpansionChanged: (value) => expand.value = value,
          title: Row(children: [
            const Text('Hidden'),
            const SizedBox(width: 4),
            Chip(
                padding: EdgeInsets.zero,
                visualDensity: const ShrinkVisualDensity(),
                backgroundColor: context.colorScheme.primary,
                label: Text(
                  widget.hiddenCount.toString(),
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
                children: widget.tags
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
                              widget.onChanged(e.name, value);
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