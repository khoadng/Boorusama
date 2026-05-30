// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/posts/pools/widgets.dart';
import '../types.dart';
import 'routes/route_utils.dart';

class SzurubooruPoolTiles extends ConsumerWidget {
  const SzurubooruPoolTiles({
    required this.pools,
    super.key,
  });

  final List<SzurubooruPool> pools;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PoolTileList<SzurubooruPool>(
      pools: pools,
      name: (pool) => pool.name,
      postCount: (pool) => pool.postCount,
      onTap: goToSzurubooruPoolDetailPage,
    );
  }
}
