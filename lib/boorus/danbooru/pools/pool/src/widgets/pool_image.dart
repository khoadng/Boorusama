// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/images/booru_image.dart';
import '../../../../../../core/settings/providers.dart';
import '../../types.dart';
import '../providers/pool_covers_notifier.dart';

class PoolImage extends ConsumerWidget {
  const PoolImage({
    required this.pool,
    super.key,
  });

  final DanbooruPool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cover = ref.watch(danbooruPoolCoverProvider(pool.id));
    final imageBorderRadius = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageBorderRadius),
    );

    return LayoutBuilder(
      builder: (context, constraints) => cover != null
          ? cover.url != null
                ? BooruImage(
                    config: ref.watchConfigAuth,
                    aspectRatio: 0.6,
                    imageUrl: cover.url!,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.all(
                      Radius.circular(imageBorderRadius),
                    ),
                  )
                : AspectRatio(
                    aspectRatio: 0.6,
                    child: Container(
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.all(
                          Radius.circular(imageBorderRadius),
                        ),
                      ),
                      child: Center(
                        child: Text(context.t.pool.no_cover_image),
                      ),
                    ),
                  )
          : AspectRatio(
              aspectRatio: 0.6,
              child: Container(
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.all(
                    Radius.circular(imageBorderRadius),
                  ),
                ),
              ),
            ),
    );
  }
}
