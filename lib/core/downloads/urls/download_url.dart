// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../posts/post/post.dart';
import '../../settings.dart';

class DownloadUrlData extends Equatable {
  const DownloadUrlData({
    required this.url,
    required this.cookie,
  });

  const DownloadUrlData.urlOnly(
    this.url,
  ) : cookie = null;

  final String url;
  final String? cookie;

  @override
  List<Object?> get props => [url, cookie];
}

abstract interface class DownloadFileUrlExtractor {
  Future<DownloadUrlData?> getDownloadFileUrl({
    required Post post,
    required DownloadQuality quality,
  });
}

final class UrlInsidePostExtractor implements DownloadFileUrlExtractor {
  const UrlInsidePostExtractor();

  @override
  Future<DownloadUrlData?> getDownloadFileUrl({
    required Post post,
    required DownloadQuality quality,
  }) async {
    if (post.isVideo) return DownloadUrlData.urlOnly(post.videoUrl);

    final urls = [
      post.originalImageUrl,
      post.sampleImageUrl,
      post.thumbnailImageUrl,
    ];

    final url = switch (quality) {
      DownloadQuality.original => urls.firstWhereOrNull((e) => e.isNotEmpty),
      DownloadQuality.sample =>
        urls.skip(1).firstWhereOrNull((e) => e.isNotEmpty),
      DownloadQuality.preview => post.thumbnailImageUrl,
    };

    return url != null ? DownloadUrlData.urlOnly(url) : null;
  }
}
