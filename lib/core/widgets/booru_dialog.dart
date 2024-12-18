// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

class BooruDialog extends StatelessWidget {
  const BooruDialog({
    super.key,
    this.color,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.barrierColor,
    this.dismissible = true,
    required this.child,
  });

  final Color? color;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget child;
  final Color? barrierColor;
  final bool dismissible;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.pop(context),
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: dismissible ? () => Navigator.pop(context) : null,
            child: Container(
              color: barrierColor ?? Colors.transparent,
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
            ),
          ),
          Material(
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(context).colorScheme.hintColor,
                width: 0.25,
              ),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth:
                    min(MediaQuery.sizeOf(context).width * 0.8, width ?? 500),
                maxHeight:
                    min(MediaQuery.sizeOf(context).height * 0.9, height ?? 800),
              ),
              decoration: BoxDecoration(
                borderRadius: borderRadius ?? BorderRadius.circular(8),
                color: color,
              ),
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
