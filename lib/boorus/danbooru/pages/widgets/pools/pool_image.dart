// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class PoolImage extends ConsumerWidget {
  const PoolImage({
    super.key,
    required this.pool,
  });

  final Pool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cover = ref.watch(danbooruPoolCoverProvider(pool.id));

    return LayoutBuilder(
      builder: (context, constraints) => cover != null
          ? cover.url != null
              ? BooruImage(
                  width: constraints.maxWidth,
                  aspectRatio: 0.6,
                  imageUrl: cover.url!,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                )
              : AspectRatio(
                  aspectRatio: 0.6,
                  child: Container(
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceVariant,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    child: const Center(
                      child: Text('No cover image'),
                    ),
                  ),
                )
          : AspectRatio(
              aspectRatio: 0.6,
              child: Container(
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceVariant,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
    );
  }
}
