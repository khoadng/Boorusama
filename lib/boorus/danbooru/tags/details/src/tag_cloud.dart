// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_scatter/flutter_scatter.dart';

class TagCloud extends StatelessWidget {
  const TagCloud({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.scaleFactor,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double? scaleFactor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: switch (constraints.maxWidth) {
              > 500 => 240,
              > 300 => 180,
              > 250 => 140,
              > 200 => 120,
              _ => 80,
            } *
            (scaleFactor ?? 1.0),
        child: FittedBox(
          child: Scatter(
            fillGaps: true,
            delegate: FermatSpiralScatterDelegate(
              ratio: size.aspectRatio,
            ),
            children: [
              for (var i = 0; i < itemCount; i++) itemBuilder(context, i),
            ],
          ),
        ),
      ),
    );
  }
}
