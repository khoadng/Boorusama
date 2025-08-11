// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/info/device_info.dart';
import '../../../../configs/config/types.dart';
import '../../../../http/providers.dart';
import '../../../../images/providers.dart';
import '../../../post/post.dart';

class PostDetailsPreloadImage<T extends Post> extends ConsumerWidget {
  const PostDetailsPreloadImage({
    required this.url,
    required this.post,
    required this.config,
    super.key,
  });

  final T post;
  final String url;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (post.originalImageUrl == url) {
      return const SizedBox.shrink();
    }

    final dio = ref.watch(dioForWidgetProvider(config));
    final deviceInfo = ref.watch(deviceInfoProvider);

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
          dio: dio,
          width: 1,
          height: 1,
          cacheHeight: 10,
          cacheWidth: 10,
          headers: ref.watch(httpHeadersProvider(config)),
          platform: Theme.of(context).platform,
          androidVersion: deviceInfo.androidDeviceInfo?.version.sdkInt,
          cacheManager: ref.watch(defaultImageCacheManagerProvider),
        );
      },
    );
  }
}
