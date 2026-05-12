// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/config/providers.dart';
import '../../../../core/posts/pools/widgets.dart';
import '../providers.dart';
import '../types.dart';
import 'pool_image.dart';
import 'routes/route_utils.dart';

class SzurubooruPoolPagedSliverGrid extends ConsumerWidget {
  const SzurubooruPoolPagedSliverGrid({
    required this.constraints,
    required this.order,
    super.key,
    this.name,
  });

  final BoxConstraints constraints;
  final SzurubooruPoolOrder order;
  final String? name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PoolPagedSliverGridView<SzurubooruPool>(
      constraints: constraints,
      refreshKey: (order, name),
      fetchPage: (ref, pageKey) {
        final config = ref.readConfigAuth;
        final repo = ref.read(szurubooruPoolRepoProvider(config));

        return repo.getPools(
          page: pageKey,
          order: order,
          name: name,
        );
      },
      imageBuilder: (context, pool) => SzurubooruPoolImage(pool: pool),
      onTap: goToSzurubooruPoolDetailPage,
      total: (pool) => pool.postCount,
      name: (pool) => pool.name,
    );
  }
}
