// Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Project imports:
import 'package:boorusama/core/domain/posts.dart';

class PostPreviewPreloaderImp implements PostPreviewPreloader {
  PostPreviewPreloaderImp(
    this.cache, {
    this.httpHeaders,
  });

  final CacheManager cache;
  final Map<String, String>? httpHeaders;

  @override
  Future<void> preload(Post post) {
    if (post.thumbnailImageUrl.isEmpty) return Future.value();

    return cache.downloadFile(
      post.thumbnailImageUrl,
      authHeaders: httpHeaders,
    );
  }
}
