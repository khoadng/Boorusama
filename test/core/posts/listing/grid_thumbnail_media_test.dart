// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/images/types.dart';
import 'package:boorusama/core/posts/listing/types.dart';

import '../../../support/fakes/test_post.dart';

void main() {
  final gif = TestPost(
    id: 1,
    format: '.gif',
    thumbnailImageUrl: 'thumbnail',
    sampleImageUrl: 'sample',
    originalImageUrl: 'original',
  );

  final cases = [
    (quality: ImageQuality.automatic, autoplay: 'sample'),
    (quality: ImageQuality.low, autoplay: 'thumbnail'),
    (quality: ImageQuality.high, autoplay: 'sample'),
    (quality: ImageQuality.highest, autoplay: 'sample'),
    (quality: ImageQuality.original, autoplay: 'original'),
  ];

  for (final c in cases) {
    test('a gif at ${c.quality.name} quality shows the still thumbnail '
        'when autoplay is off', () {
      final media = defaultGridThumbnailMedia(
        gif,
        _settings(c.quality, AnimatedPostsDefaultState.static),
      );

      expect(media.url, 'thumbnail');
    });

    test('a gif at ${c.quality.name} quality loads ${c.autoplay} '
        'when autoplay is on', () {
      final media = defaultGridThumbnailMedia(
        gif,
        _settings(c.quality, AnimatedPostsDefaultState.autoplay),
      );

      expect(media.url, c.autoplay);
    });
  }
}

GridThumbnailSettings _settings(
  ImageQuality quality,
  AnimatedPostsDefaultState state,
) => GridThumbnailSettings(
  imageQuality: quality,
  animatedPostsDefaultState: state,
  gridSize: GridSize.normal,
);
