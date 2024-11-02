// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/pools/pools.dart';

class DanbooruPoolGridItem extends ConsumerWidget {
  const DanbooruPoolGridItem({
    super.key,
    required this.pool,
  });

  final DanbooruPool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PoolGridItem(
      image: PoolImage(pool: pool),
      onTap: () => goToPoolDetailPage(context, pool),
      total: pool.postCount,
      name: pool.name,
    );
  }
}
