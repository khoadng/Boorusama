// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/core.dart';

String getImageUrlForDisplay(Post post, ImageQuality quality) {
  if (post.isAnimated) return post.previewImageUrl;
  if (quality == ImageQuality.low) return post.previewImageUrl;

  return post.normalImageUrl;
}
