// Flutter imports:
import 'package:flutter/material.dart';

class CompactChip extends StatelessWidget {
  const CompactChip({
    super.key,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
  });

  final void Function()? onTap;
  final String label;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: borderRadius ?? BorderRadius.circular(6),
      color: backgroundColor,
      child: InkWell(
        borderRadius: borderRadius ?? BorderRadius.circular(6),
        onTap: () => onTap?.call(),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 4,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
