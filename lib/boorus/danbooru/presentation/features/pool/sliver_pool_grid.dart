// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/utils.dart';
import 'pool_image.dart';

class SliverPoolGrid extends StatelessWidget {
  const SliverPoolGrid({
    Key? key,
    required this.pools,
  }) : super(key: key);

  final List<PoolItem> pools;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return PoolGridItem(pool: pools[index]);
        },
        childCount: pools.length,
      ),
    );
  }
}

class PoolGridItem extends StatelessWidget {
  const PoolGridItem({
    Key? key,
    required this.pool,
  }) : super(key: key);

  final PoolItem pool;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: GestureDetector(
          onTap: () => AppRouter.router.navigateTo(
            context,
            'pool/detail',
            routeSettings: RouteSettings(arguments: [
              pool.pool,
            ]),
          ),
          child: Column(
            children: [
              Expanded(
                child: PoolImage(pool: pool),
              ),
              ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  subtitle: const Text('pool.item').plural(pool.pool.postCount),
                  title: Text(
                    pool.pool.name.removeUnderscoreWithSpace(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
