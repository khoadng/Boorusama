// Flutter imports:
import 'package:flutter/material.dart';

class MultiSelectionActionBar extends StatelessWidget {
  const MultiSelectionActionBar({
    required this.children,
    this.height,
    super.key,
  });

  final List<Widget> children;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      child: children.length < 4
          ? OverflowBar(
              alignment: MainAxisAlignment.center,
              spacing: 4,
              children: children,
            )
          : SizedBox(
              height: height ?? 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: children,
              ),
            ),
    );
  }
}
