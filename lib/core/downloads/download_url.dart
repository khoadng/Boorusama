// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';

abstract interface class DownloadFileUrlExtractor {
  Future<String?> getDownloadFileUrl({
    required Post post,
    required Settings settings,
  });
}

final class UrlInsidePostExtractor implements DownloadFileUrlExtractor {
  const UrlInsidePostExtractor();

  @override
  Future<String?> getDownloadFileUrl({
    required Post post,
    required Settings settings,
  }) async {
    if (post.isVideo) return post.videoUrl;

    final urls = [
      post.originalImageUrl,
      post.sampleImageUrl,
      post.thumbnailImageUrl
    ];

    return switch (settings.downloadQuality) {
      DownloadQuality.original => urls.firstWhereOrNull((e) => e.isNotEmpty),
      DownloadQuality.sample =>
        urls.skip(1).firstWhereOrNull((e) => e.isNotEmpty),
      DownloadQuality.preview => post.thumbnailImageUrl,
    };
  }
}
