// Flutter imports:
import 'package:flutter/material.dart';

class SimpleIconButton extends StatelessWidget {
  const SimpleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.borderRadius,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius ?? BorderRadius.circular(6),
        onTap: onPressed,
        child: icon,
      ),
    );
  }
}
