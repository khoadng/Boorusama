// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/networking/dio.dart';
import '../../../foundation/http/http.dart';

extension PostDetailsUtils<T extends Post> on List<T> {
  (T? prev, T? next) getPrevAndNextPosts(int index) {
    final next = index + 1 < length ? this[index + 1] : null;
    final prev = index - 1 >= 0 ? this[index - 1] : null;

    return (prev, next);
  }
}

class PostDetailsPreloadImage<T extends Post> extends ConsumerWidget {
  const PostDetailsPreloadImage({
    super.key,
    required this.url,
    required this.post,
  });

  final String url;
  final T post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (post.originalImageUrl == url) {
      return const SizedBox.shrink();
    }

    final config = ref.watchConfig;

    return FutureBuilder(
      // Delay to prevent the image from loading too early
      future: Future.delayed(const Duration(milliseconds: 500)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        return ExtendedImage.network(
          url,
          width: 1,
          height: 1,
          cacheHeight: 10,
          cacheWidth: 10,
          headers: {
            AppHttpHeaders.userAgentHeader:
                ref.watch(userAgentGeneratorProvider(config)).generate(),
            ...ref.watch(extraHttpHeaderProvider(config)),
            ...ref.watch(cachedBypassDdosHeadersProvider(config.url)),
          },
        );
      },
    );
  }
}
