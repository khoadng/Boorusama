// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../posts/post/post.dart';

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
    required String quality,
  });
}

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
