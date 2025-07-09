// Flutter imports:
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.padding,
    this.dense = false,
  });

  final void Function()? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          padding ??
          (dense
              ? const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                )
              : const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                )),
      child: FilledButton(
        style: FilledButton.styleFrom(
          shape: dense
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          minimumSize: dense ? const Size(0, 36) : const Size(0, 48),
          padding: dense
              ? const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                )
              : null,
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
