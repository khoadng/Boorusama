// Flutter imports:
import 'package:flutter/material.dart';

class SheetDragline extends StatelessWidget {
  const SheetDragline({
    super.key,
    this.maxWidth = 120,
    this.minWidth = 80,
    this.height = 4,
    this.isHolding = false,
    this.padding,
  });

  final double maxWidth;
  final double minWidth;
  final double height;
  final bool isHolding;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      child: ColoredBox(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: padding ??
                  const EdgeInsets.only(
                    top: 6,
                    bottom: 28,
                  ),
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isHolding ? maxWidth : minWidth,
                height: height,
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color:
                      isHolding ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
