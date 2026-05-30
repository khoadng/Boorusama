// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/posts/pools/widgets.dart';
import '../../../details/routes.dart';
import '../types/danbooru_pool.dart';

class PoolTiles extends ConsumerWidget {
  const PoolTiles({
    required this.pools,
    super.key,
  });

  final List<DanbooruPool> pools;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PoolTileList<DanbooruPool>(
      pools: pools,
      name: (pool) => pool.name,
      postCount: (pool) => pool.postCount,
      onTap: goToPoolDetailPage,
    );
  }
}
