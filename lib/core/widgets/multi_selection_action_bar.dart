// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'adaptive_button_row.dart';
import 'multi_select_button.dart';

class MultiSelectionActionBar extends StatelessWidget {
  const MultiSelectionActionBar({
    required this.children,
    this.height,
    super.key,
  });

  final List<MultiSelectButton> children;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: AdaptiveButtonRow.scrollable(
        buttons: children
            .map(
              (button) => ButtonData(
                widget: button,
                title: button.name,
                onTap: button.onPressed,
              ),
            )
            .toList(),
        spacing: 4,
        buttonWidth: 86,
      ),
    );
  }
}
