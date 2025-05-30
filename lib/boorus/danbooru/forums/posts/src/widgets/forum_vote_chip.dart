// Flutter imports:
import 'package:flutter/material.dart';

class ForumVoteChip extends StatelessWidget {
  const ForumVoteChip({
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.label,
    super.key,
    this.borderRadius,
  });

  final Color color;
  final Color borderColor;
  final Widget icon;
  final BorderRadius? borderRadius;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        border: Border.all(
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
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
