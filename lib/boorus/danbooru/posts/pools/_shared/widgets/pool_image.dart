// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/images/booru_image.dart';
import 'package:boorusama/core/settings/data/listing_provider.dart';
import '../../pool/pool.dart';
import '../providers/pool_covers_notifier.dart';

class PoolImage extends ConsumerWidget {
  const PoolImage({
    super.key,
    required this.pool,
  });

  final DanbooruPool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cover = ref.watch(danbooruPoolCoverProvider(pool.id));
    final imageBorderRadius = ref.watch(imageListingSettingsProvider
        .select((value) => value.imageBorderRadius));

    return LayoutBuilder(
      builder: (context, constraints) => cover != null
          ? cover.url != null
              ? BooruImage(
                  width: constraints.maxWidth,
                  aspectRatio: 0.6,
                  imageUrl: cover.url!,
                  fit: BoxFit.cover,
                  borderRadius:
                      BorderRadius.all(Radius.circular(imageBorderRadius)),
                )
              : AspectRatio(
                  aspectRatio: 0.6,
                  child: Container(
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius:
                          BorderRadius.all(Radius.circular(imageBorderRadius)),
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
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius:
                      BorderRadius.all(Radius.circular(imageBorderRadius)),
                ),
              ),
            ),
    );
  }
}
