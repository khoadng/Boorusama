// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:selection_mode/selection_mode.dart';

class DownloadSelectableItem extends StatelessWidget {
  const DownloadSelectableItem({
    required this.index,
    required this.item,
    super.key,
  });

  final int index;
  final Widget item;

  @override
  Widget build(BuildContext context) {
    return SelectableBuilder(
      index: index,
      builder: (context, isSelected) {
        final controller = SelectionMode.of(context);
        final multiSelect = controller.isActive;
        final selectedItems = controller.selection;

        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: multiSelect ? 48 : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: multiSelect ? 1.0 : 0.0,
                child: multiSelect
                    ? Checkbox(
                        value: selectedItems.contains(index),
                        onChanged: (value) {
                          if (value == null) return;
                          controller.toggleItem(index);
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: item,
            ),
          ],
        );
      },
    );
  }
}
