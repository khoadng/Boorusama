// Flutter imports:
import 'package:flutter/material.dart';

class BooruDialog extends StatelessWidget {
  const BooruDialog({
    super.key,
    this.color,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    required this.child,
  });

  final Color? color;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
          ),
        ),
        Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: color,
              width: width,
              height: height,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
