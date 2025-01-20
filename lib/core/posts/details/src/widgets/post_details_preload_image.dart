// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/ref.dart';
import '../../../../http/providers.dart';
import '../../../../images/providers.dart';

class PostDetailsPreloadImage extends ConsumerWidget {
  const PostDetailsPreloadImage({
    required this.url,
    super.key,
  });

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final dio = ref.watch(dioProvider(config));

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
          headers: {
            ...ref.watch(extraHttpHeaderProvider(config)),
          },
        );
      },
    );
  }
}
