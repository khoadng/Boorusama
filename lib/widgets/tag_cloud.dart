// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_scatter/flutter_scatter.dart';

// Project imports:
import 'package:boorusama/flutter.dart';

class TagCloud extends StatelessWidget {
  const TagCloud({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 180),
      child: FittedBox(
        child: Scatter(
          fillGaps: true,
          delegate: FermatSpiralScatterDelegate(
            ratio: context.screenAspectRatio,
          ),
          children: [
            for (var i = 0; i < itemCount; i++) itemBuilder(context, i)
          ],
        ),
      ),
    );
  }
}
