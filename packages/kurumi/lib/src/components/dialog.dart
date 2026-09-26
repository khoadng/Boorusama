import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

class KurumiDialog extends StatelessWidget {
  const KurumiDialog({
    required this.child,
    super.key,
    this.color,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.barrierColor,
    this.dismissible = true,
    this.semanticLabel,
  });

  final Color? color;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget child;
  final Color? barrierColor;
  final bool dismissible;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Semantics(
      scopesRoute: true,
      namesRoute: semanticLabel != null,
      explicitChildNodes: true,
      label: semanticLabel,
      child: CallbackShortcuts(
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
                width: size.width,
                height: size.height,
              ),
            ),
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.circular(28),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: min(
                    size.width * 0.85,
                    width ?? 500,
                  ),
                  maxHeight: min(
                    size.height * 0.9,
                    height ?? 800,
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: borderRadius ?? BorderRadius.circular(28),
                  color: color,
                ),
                padding: padding ?? const EdgeInsets.all(24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
