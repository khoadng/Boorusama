// Flutter imports:
import 'package:flutter/material.dart';

class DragLine extends StatelessWidget {
  const DragLine({
    super.key,
    this.padding,
  });

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding,
      width: 48,
      height: 6,
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: Theme.of(context).hintColor,
      ),
    );
  }
}
