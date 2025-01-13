// Flutter imports:
import 'package:flutter/material.dart';

class SheetDragline extends StatelessWidget {
  const SheetDragline({
    super.key,
    this.maxWidth = 120,
    this.minWidth = 80,
    this.isHolding = false,
  });

  final double maxWidth;
  final double minWidth;
  final bool isHolding;

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
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 24,
              ),
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isHolding ? maxWidth : minWidth,
                height: 4,
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
