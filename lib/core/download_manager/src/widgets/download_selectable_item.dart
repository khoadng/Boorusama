// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/widgets.dart';

class DownloadSelectableItem extends StatelessWidget {
  const DownloadSelectableItem({
    required this.multiSelectController,
    required this.index,
    required this.item,
    super.key,
  });

  final MultiSelectController multiSelectController;
  final int index;
  final Widget item;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: multiSelectController.multiSelectNotifier,
      builder: (_, multiSelect, _) => Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: multiSelect ? 48 : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: multiSelect ? 1.0 : 0.0,
              child: multiSelect
                  ? ValueListenableBuilder(
                      valueListenable:
                          multiSelectController.selectedItemsNotifier,
                      builder: (_, selectedItems, _) => Checkbox(
                        value: selectedItems.contains(index),
                        onChanged: (value) {
                          if (value == null) return;
                          multiSelectController.toggleSelection(index);
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: item,
          ),
        ],
      ),
    );
  }
}
