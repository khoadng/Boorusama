// Flutter imports:
import 'package:flutter/material.dart';

class GrayedOut extends StatelessWidget {
  const GrayedOut({
    required this.child,
    super.key,
    this.grayedOut = true,
  });

  final Widget child;
  final bool grayedOut;

  @override
  Widget build(BuildContext context) {
    return grayedOut
        ? Stack(
            children: [
              Opacity(
                opacity: 0.3,
                child: IgnorePointer(
                  child: child,
                ),
              ),
            ],
          )
        : child;
  }
}
