// Flutter imports:
import 'package:flutter/material.dart';

class NullableAspectRatio extends StatelessWidget {
  const NullableAspectRatio({
    super.key,
    this.aspectRatio,
    required this.child,
  });

  final double? aspectRatio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return aspectRatio == null
        ? child
        : AspectRatio(
            aspectRatio: aspectRatio!,
            child: child,
          );
  }
}
