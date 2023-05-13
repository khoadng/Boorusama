// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/core/application/settings.dart';
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
    final size = screenWidthToDisplaySize(MediaQuery.of(context).size.width);

    return SliverGrid(
      gridDelegate: switch (size) {
        ScreenSize.small ||
        ScreenSize.medium =>
          SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: spacing,
            crossAxisCount: 2,
            childAspectRatio: 0.5,
          ),
        ScreenSize.large ||
        ScreenSize.veryLarge =>
          SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: spacing,
            crossAxisCount: 5,
            childAspectRatio: 0.6,
          ),
      },
      delegate: SliverChildBuilderDelegate(
        (_, index) => PoolGridItem(pool: pools[index]),
        childCount: pools.length,
      ),
    );
  }
}
