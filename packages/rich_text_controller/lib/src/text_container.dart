import 'package:flutter/material.dart';

class TextContainer extends StatelessWidget {
  const TextContainer({
    super.key,
    required this.text,
    this.decoration,
    this.textStyle,
    this.contentPadding,
    this.padding,
  });

  final String text;
  final TextStyle? textStyle;
  final Decoration? decoration;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 6),
      decoration:
          decoration ??
          BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              bottomLeft: Radius.circular(6),
            ),
          ),
      child: Padding(
        padding: contentPadding ?? const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style:
              textStyle ??
              TextStyle(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
        ),
      ),
    );
  }
}
