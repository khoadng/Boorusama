// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/engine/providers.dart';
import '../../configs/config/types.dart';
import '../../posts/post/post.dart';
import 'types.dart';

final downloadFileUrlExtractorProvider =
    Provider.family<DownloadFileUrlExtractor, BooruConfigAuth>(
      (ref, config) {
        final repo = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        final downloadFileUrlExtractor = repo?.downloadFileUrlExtractor(config);

        if (downloadFileUrlExtractor != null) {
          return downloadFileUrlExtractor;
        }

        return const UrlInsidePostExtractor();
      },
    );

final class UrlInsidePostExtractor implements DownloadFileUrlExtractor {
  const UrlInsidePostExtractor();

  @override
  Future<DownloadUrlData?> getDownloadFileUrl({
    required Post post,
    required String quality,
  }) async {
    if (post.isVideo) return DownloadUrlData.urlOnly(post.videoUrl);

    final urls = [
      post.originalImageUrl,
      post.sampleImageUrl,
      post.thumbnailImageUrl,
    ];

    final url = switch (quality) {
      'original' => urls.firstWhereOrNull((e) => e.isNotEmpty),
      'sample' => urls.skip(1).firstWhereOrNull((e) => e.isNotEmpty),
      'preview' => post.thumbnailImageUrl,
      _ => urls.firstWhereOrNull((e) => e.isNotEmpty),
    };

    return url != null ? DownloadUrlData.urlOnly(url) : null;
  }
}
