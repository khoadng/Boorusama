// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../settings/settings.dart';
import '../../../post/post.dart';

abstract class GridThumbnailUrlGenerator {
  String generateUrl(
    Post post, {
    required GridThumbnailSettings settings,
  });
}

typedef ImageQualityMapper =
    String Function(
      Post post,
      ImageQuality imageQuality,
      GridSize gridSize,
    );

typedef GifImageQualityMapper =
    String Function(
      Post post,
      ImageQuality imageQuality,
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
