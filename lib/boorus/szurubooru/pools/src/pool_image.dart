// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../core/configs/config/providers.dart';
import '../../../../core/images/booru_image.dart';
import '../../../../core/settings/providers.dart';
import '../types.dart';

class SzurubooruPoolImage extends ConsumerWidget {
  const SzurubooruPoolImage({
    required this.pool,
    super.key,
  });

  final SzurubooruPool pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageBorderRadius = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageBorderRadius),
    );

    return switch (pool.thumbnailUrls.firstOrNull) {
      final url? => BooruImage(
        config: ref.watchConfigAuth,
        aspectRatio: 0.6,
        imageUrl: url,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.all(
          Radius.circular(imageBorderRadius),
        ),
      ),
      _ => AspectRatio(
        aspectRatio: 0.6,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.all(
              Radius.circular(imageBorderRadius),
            ),
          ),
          child: Center(
            child: Text(context.t.pool.no_cover_image),
          ),
        ),
      ),
    };
  }
}
