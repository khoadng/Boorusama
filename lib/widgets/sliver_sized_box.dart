// Flutter imports:
import 'package:flutter/material.dart';

class SliverSizedBox extends StatelessWidget {
  const SliverSizedBox({
    super.key,
    this.height,
    this.width,
    this.child,
  });

  const SliverSizedBox.shrink({
    super.key,
  })  : height = 0,
        width = 0,
        child = null;

  final double? height;
  final double? width;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: height,
        width: width,
      ),
    );
  }
}
