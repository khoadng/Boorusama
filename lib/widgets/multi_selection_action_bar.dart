// Flutter imports:
import 'package:flutter/material.dart';

class MultiSelectionActionBar extends StatelessWidget {
  const MultiSelectionActionBar({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 12,
      ),
      child: OverflowBar(
        alignment: MainAxisAlignment.center,
        spacing: 4,
        children: children,
      ),
    );
  }
}
