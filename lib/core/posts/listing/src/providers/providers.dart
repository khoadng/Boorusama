// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config.dart';
import '../../../../settings/providers.dart';
import '../types/grid_size.dart';
import '../types/grid_thumbnail_url_generator.dart';
import '../types/grid_thumbnail_url_generator_default.dart';

final gridThumbnailSettingsProvider =
    Provider.family<GridThumbnailSettings, BooruConfigAuth>((ref, config) {
      final (quality, animatedState, gridSize) = ref.watch(
        imageListingSettingsProvider.select(
          (value) => (
            value.imageQuality,
            value.animatedPostsDefaultState,
            value.gridSize,
          ),
        ),
      );

      return GridThumbnailSettings(
        imageQuality: quality,
        animatedPostsDefaultState: animatedState,
        gridSize: gridSize,
      );
    });

final gridThumbnailUrlGeneratorProvider =
    Provider.family<GridThumbnailUrlGenerator, BooruConfigAuth>((ref, config) {
      final booruRepo = ref.watch(booruRepoProvider(config));

      return booruRepo?.gridThumbnailUrlGenerator(config) ??
          const DefaultGridThumbnailUrlGenerator();
    });

final selectionIndicatorSizeProvider = Provider<double>((ref) {
  final gridSize = ref.watch(
    imageListingSettingsProvider.select((value) => value.gridSize),
  );

  return 32 * _getGridSizeFactor(gridSize);
});

double _getGridSizeFactor(GridSize gridSize) => switch (gridSize) {
  GridSize.small => 0.95,
  GridSize.normal => 1.0,
  GridSize.large => 1.05,
  GridSize.tiny => 0.85,
  GridSize.micro => 0.75,
};
