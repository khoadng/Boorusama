// Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Project imports:
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/domain/posts/post_preloader.dart';

class PostPreviewPreloaderImp implements PostPreviewPreloader {
  PostPreviewPreloaderImp(this.cache);

  final CacheManager cache;

  @override
  Future<void> preload(Post post) {
    return cache.downloadFile(post.previewImageUrl);
  }
}
