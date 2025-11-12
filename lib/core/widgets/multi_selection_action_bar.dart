// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../settings/providers.dart';
import 'adaptive_button_row.dart';
import 'multi_select_button.dart';

class MultiSelectionActionBar extends ConsumerWidget {
  const MultiSelectionActionBar({
    required this.children,
    this.height,
    super.key,
  });

  final List<Widget> children;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceAnimation = ref.watch(
      settingsProvider.select(
        (value) => value.reduceAnimations,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: AdaptiveButtonRow.menu(
        reduceAnimation: reduceAnimation,
        buttons: children
            .map(
              (button) => switch (button) {
                MultiSelectButton() => ButtonData(
                  widget: button,
                  title: button.name,
                  onTap: button.onPressed,
                ),
                _ => ButtonData(
                  widget: button,
                  title: 'Button',
                  onTap: () {},
                ),
              },
            )
            .toList(),
        spacing: 4,
        buttonWidth: 86,
      ),
    );
  }
}
