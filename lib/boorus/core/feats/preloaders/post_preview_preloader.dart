// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'post_preloader.dart';

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

    try {
      return cache.downloadFile(
        post.thumbnailImageUrl,
        authHeaders: httpHeaders,
      );
    } catch (e) {
      if (e is SocketException) {
        // Do nothing
        return Future.value();
      } else {
        rethrow;
      }
    }
  }
}
