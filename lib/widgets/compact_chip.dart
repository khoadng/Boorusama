// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

class CompactChip extends StatelessWidget {
  const CompactChip({
    super.key,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  final void Function()? onTap;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
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
            horizontal: 6,
          ),
          child: AutoSizeText(
            label,
            softWrap: false,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
