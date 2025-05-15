// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../settings/providers.dart';
import '../types/grid_thumbnail_url_generator.dart';
import '../types/grid_thumbnail_url_generator_default.dart';

final gridThumbnailSettingsProvider = Provider<GridThumbnailSettings>((ref) {
  final (quality, animatedState) = ref.watch(
    imageListingSettingsProvider.select(
      (value) => (value.imageQuality, value.animatedPostsDefaultState),
    ),
  );

  return GridThumbnailSettings(
    imageQuality: quality,
    animatedPostsDefaultState: animatedState,
  );
});

final gridThumbnailUrlGeneratorProvider =
    Provider<GridThumbnailUrlGenerator>((ref) {
  final booruRepo = ref.watch(currentBooruRepoProvider);

  return booruRepo?.gridThumbnailUrlGenerator() ??
      const DefaultGridThumbnailUrlGenerator();
});
