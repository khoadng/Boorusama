// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/posts/pools/widgets.dart';
import '../../../details/routes.dart';
import '../../providers.dart';
import '../../types.dart';
import 'pool_image.dart';

class PoolPagedSliverGrid extends ConsumerWidget {
  const PoolPagedSliverGrid({
    required this.constraints,
    required this.order,
    required this.category,
    super.key,
    this.name,
    this.description,
  });

  final BoxConstraints constraints;
  final DanbooruPoolOrder order;
  final DanbooruPoolCategory category;
  final String? name;
  final String? description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PoolPagedSliverGridView<DanbooruPool>(
      constraints: constraints,
      refreshKey: (order, category, name, description),
      fetchPage: (ref, pageKey) async {
        final config = ref.readConfigSearch;
        final repo = ref.read(danbooruPoolRepoProvider(config.auth));
        final newItems = await repo.getPools(
          pageKey,
          category: category,
          order: order,
          name: name,
          description: description,
        );

        unawaited(
          ref.read(danbooruPoolCoversProvider(config).notifier).load(newItems),
        );

        return newItems;
      },
      imageBuilder: (context, pool) => PoolImage(pool: pool),
      onTap: goToPoolDetailPage,
      total: (pool) => pool.postCount,
      name: (pool) => pool.name,
    );
  }
}
