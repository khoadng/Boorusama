// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

class FloatingGlassyCard extends StatelessWidget {
  const FloatingGlassyCard({
    Key? key,
    required this.child,
    this.width,
  }) : super(key: key);

  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          elevation: 12,
          color: Theme.of(context).cardColor.withOpacity(0.7),
          type: MaterialType.card,
          child: SizedBox(
            width: width ?? MediaQuery.of(context).size.width * 0.9,
            child: child,
          ),
        ),
      ),
    );
  }
}
