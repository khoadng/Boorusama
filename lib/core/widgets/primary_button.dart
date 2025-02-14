// Flutter imports:
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.padding,
  });

  final void Function()? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding ??
          const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 12,
          ),
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
