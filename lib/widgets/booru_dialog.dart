// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';

class BooruDialog extends StatelessWidget {
  const BooruDialog({
    super.key,
    this.color,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.barrierColor,
    required this.child,
  });

  final Color? color;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget child;
  final Color? barrierColor;

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
            onTap: () => Navigator.pop(context),
            child: Container(
              color: barrierColor ?? Colors.transparent,
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
            ),
          ),
          Material(
            color: context.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth:
                    min(MediaQuery.sizeOf(context).width * 0.8, width ?? 500),
                maxHeight:
                    min(MediaQuery.sizeOf(context).height * 0.8, height ?? 800),
              ),
              decoration: BoxDecoration(
                borderRadius: borderRadius ?? BorderRadius.circular(8),
                color: color,
              ),
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
