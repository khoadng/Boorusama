// Flutter imports:
import 'package:flutter/material.dart';

class SquareChip extends StatelessWidget {
  const SquareChip({
    super.key,
    this.color,
    this.borderRadius,
    required this.label,
  });

  final Color? color;
  final BorderRadius? borderRadius;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(2)),
      ),
      child: label,
    );
  }
}
