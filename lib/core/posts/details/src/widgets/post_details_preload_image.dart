// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/ref.dart';
import '../../../../http/providers.dart';
import '../../../../images/dio_extended_image.dart';
import '../../../../images/providers.dart';

class PostDetailsPreloadImage extends ConsumerWidget {
  const PostDetailsPreloadImage({
    super.key,
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final dio = ref.watch(dioProvider(config));

    return DioExtendedImage.network(
      url,
      dio: dio,
      width: 1,
      height: 1,
      cacheHeight: 10,
      cacheWidth: 10,
      cacheMaxAge: kDefaultImageCacheDuration,
      headers: {
        ...ref.watch(extraHttpHeaderProvider(config)),
      },
    );
  }
}
