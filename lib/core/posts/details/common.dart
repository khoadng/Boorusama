// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';

// Project imports:
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';

extension PostDetailsUtils<T extends Post> on List<T> {
  (T? prev, T? next) getPrevAndNextPosts(int index) {
    final next = index + 1 < length ? this[index + 1] : null;
    final prev = index - 1 >= 0 ? this[index - 1] : null;

    return (prev, next);
  }
}

class PostDetailsPreloadImage extends StatelessWidget {
  const PostDetailsPreloadImage({
    super.key,
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url,
      width: 1,
      height: 1,
      cacheHeight: 10,
      cacheWidth: 10,
      cacheMaxAge: kDefaultImageCacheDuration,
    );
  }
}
