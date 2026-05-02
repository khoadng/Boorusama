// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../images/types.dart';
import '../../../post/types.dart';
import 'animated_posts_default_state.dart';
import 'grid_size.dart';

abstract class GridThumbnailUrlGenerator {
  GridThumbnailMedia resolve(
    Post post, {
    required GridThumbnailSettings settings,
  });
}

class GridThumbnailMedia extends Equatable {
  const GridThumbnailMedia({
    required this.url,
    required this.aspectRatio,
    this.placeholderUrl,
    this.placeholderAspectRatio,
    this.placeholderFit,
  });

  final String url;
  final double? aspectRatio;
  final String? placeholderUrl;
  final double? placeholderAspectRatio;
  final BoxFit? placeholderFit;

  @override
  List<Object?> get props => [
    url,
    aspectRatio,
    placeholderUrl,
    placeholderAspectRatio,
    placeholderFit,
  ];
}

typedef GridThumbnailMediaMapper =
    GridThumbnailMedia Function(
      Post post,
      GridThumbnailSettings settings,
    );

abstract class GridLoadingPlaceholderAspectRatioResolver {
  double? resolveLoadingPlaceholderAspectRatio({
    required GridThumbnailSettings settings,
  });
}

extension GridLoadingPlaceholderAspectRatioResolverX
    on GridThumbnailUrlGenerator {
  double? resolveLoadingPlaceholderAspectRatio({
    required GridThumbnailSettings settings,
  }) {
    final generator = this;

    if (generator is GridLoadingPlaceholderAspectRatioResolver) {
      return (generator as GridLoadingPlaceholderAspectRatioResolver)
          .resolveLoadingPlaceholderAspectRatio(settings: settings);
    }

    return null;
  }
}

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
