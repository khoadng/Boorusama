// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/core/core.dart';
import 'pool_grid_item.dart';

class SliverPoolGrid extends StatelessWidget {
  const SliverPoolGrid({
    super.key,
    required this.pools,
    required this.spacing,
  });

  final List<PoolItem> pools;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: _gridSizeToGridDelegate(
        spacing: spacing,
        screenWidth: MediaQuery.of(context).size.width,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, index) => PoolGridItem(pool: pools[index]),
        childCount: pools.length,
      ),
    );
  }
}

SliverGridDelegate _gridSizeToGridDelegate({
  required double spacing,
  required double screenWidth,
}) {
  final displaySize = screenWidthToDisplaySize(screenWidth);
  switch (displaySize) {
    case ScreenSize.small:
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.5,
      );
    case ScreenSize.medium:
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.5,
      );
    default:
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.6,
      );
  }
}
