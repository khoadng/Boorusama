// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../images/types.dart';
import '../../../post/types.dart';
import 'animated_posts_default_state.dart';
import 'grid_size.dart';

abstract class GridThumbnailUrlGenerator {
  String generateUrl(
    Post post, {
    required GridThumbnailSettings settings,
  });
}

typedef ImageQualityMapper =
    String Function(
      Post post,
      GridThumbnailSettings settings,
    );

typedef GifImageQualityMapper =
    String Function(
      Post post,
      GridThumbnailSettings settings,
    );

class GridThumbnailSettings extends Equatable {
  const GridThumbnailSettings({
    required this.imageQuality,
    required this.animatedPostsDefaultState,
    required this.gridSize,
  });

  final ImageQuality imageQuality;
  final AnimatedPostsDefaultState animatedPostsDefaultState;
  final GridSize gridSize;

  @override
  List<Object?> get props => [
    imageQuality,
    animatedPostsDefaultState,
    gridSize,
  ];
}
