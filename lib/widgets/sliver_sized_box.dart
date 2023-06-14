// Flutter imports:
import 'package:flutter/material.dart';

class SliverSizedBox extends StatelessWidget {
  const SliverSizedBox({
    Key? key,
    this.height,
    this.width,
  }) : super(key: key);

  const SliverSizedBox.shrink({
    super.key,
  })  : height = 0,
        width = 0;

  final double? height;
  final double? width;

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
