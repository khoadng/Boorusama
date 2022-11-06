// Flutter imports:
import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  const CircularIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.padding,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.35),
      shape: const CircleBorder(),
      child: InkWell(
        splashFactory: InkRipple.splashFactory,
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(8),
          child: icon,
        ),
      ),
    );
  }
}
