// Flutter imports:
import 'package:flutter/material.dart';

class ForumVoteChip extends StatelessWidget {
  const ForumVoteChip({
    super.key,
    required this.icon,
    required this.color,
    required this.borderColor,
    this.borderRadius,
    required this.label,
  });

  final Color color;
  final Color borderColor;
  final Widget icon;
  final BorderRadius? borderRadius;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: borderColor,
        ),
        color: color,
        borderRadius:
            borderRadius ?? const BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Flexible(child: label),
        ],
      ),
    );
  }
}
