// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/foundation/i18n.dart';

// Project imports:

class PoolImage extends ConsumerWidget {
  const PoolImage({
    super.key,
    required this.pool,
  });

  final Pool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cover = ref.watch(danbooruPoolCoverProvider(pool.id));

    return cover != null
        ? cover.url != null
            ? BooruImage(
                aspectRatio: 0.6,
                imageUrl: cover.url!,
                fit: BoxFit.cover,
              )
            : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Center(
                  child: const Text('pool.mature_banned_content').tr(),
                ),
              )
        : Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          );
  }
}
