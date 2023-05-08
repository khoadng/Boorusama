// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/core/application/settings/settings_notifier.dart';
import 'package:boorusama/core/display.dart';
import 'pool_grid_item.dart';

class SliverPoolGrid extends ConsumerWidget {
  const SliverPoolGrid({
    super.key,
    required this.pools,
  });

  final List<PoolItem> pools;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = ref.watch(gridSpacingSettingsProvider);

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
    case ScreenSize.large:
    case ScreenSize.veryLarge:
      return const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.6,
      );
  }
}
