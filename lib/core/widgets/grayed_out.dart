// Flutter imports:
import 'package:flutter/material.dart';

class GrayedOut extends StatelessWidget {
  const GrayedOut({
    required this.child,
    super.key,
    this.grayedOut = true,
    this.stackOverlay = const [],
    this.opacity,
    this.onTap,
  });

  final Widget child;
  final bool grayedOut;
  final List<Widget> stackOverlay;
  final double? opacity;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return grayedOut
        ? Stack(
            children: [
              Opacity(
                opacity: opacity ?? 0.3,
                child: IgnorePointer(
                  child: child,
                ),
              ),
              ...stackOverlay,
              if (onTap != null)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: onTap,
                  ),
                ),
            ],
          )
        : child;
  }
}
