// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/utils.dart';
import 'pool_image.dart';

class PoolGridItem extends ConsumerWidget {
  const PoolGridItem({
    super.key,
    required this.pool,
  });

  final Pool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: GestureDetector(
        onTap: () => goToPoolDetailPage(context, pool),
        child: Column(
          children: [
            Expanded(
              child: PoolImage(pool: pool),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              subtitle: const Text('pool.item').plural(pool.postCount),
              title: Text(
                pool.name.removeUnderscoreWithSpace(),
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
