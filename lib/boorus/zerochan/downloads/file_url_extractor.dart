// Dart imports:
import 'dart:async';

// Package imports:
import 'package:booru_clients/zerochan.dart';

// Project imports:
import '../../../core/downloads/urls/types.dart';
import '../../../core/posts/post/types.dart';
import '../../../foundation/caching.dart';

class ZerochanDownloadFileUrlExtractor implements DownloadFileUrlExtractor {
  ZerochanDownloadFileUrlExtractor({
    required this.client,
  });

  final ZerochanClient client;
  final Cache<ZerochanDownloadUrls> cache = Cache(
    maxCapacity: 100,
    staleDuration: const Duration(minutes: 5),
  );
  final _pendingRequests = <String, Future<ZerochanDownloadUrls?>>{};

  @override
  Future<DownloadUrlData?> getDownloadFileUrl({
    required Post post,
    required String quality,
  }) async {
    if (quality == 'preview' && post.thumbnailImageUrl.isNotEmpty) {
      return DownloadUrlData.urlOnly(post.thumbnailImageUrl);
    }

    final urls = await _getUrls(post.id);
    final url = switch (quality) {
      'preview' => urls?.medium ?? urls?.small,
      'sample' => urls?.large ?? urls?.full,
      _ => urls?.full,
    };

    return url != null ? DownloadUrlData.urlOnly(url) : null;
  }

  Future<ZerochanDownloadUrls?> _getUrls(int postId) async {
    final key = postId.toString();
    final cached = cache.get(key);
    if (cached != null) return cached;

    final pending = _pendingRequests[key];
    if (pending != null) return pending;

    late final Future<ZerochanDownloadUrls?> request;
    request = _fetchAndCache(key, postId);
    _pendingRequests[key] = request;

    try {
      return await request;
    } finally {
      if (identical(_pendingRequests[key], request)) {
        unawaited(_pendingRequests.remove(key));
      }
    }
  }

  Future<ZerochanDownloadUrls?> _fetchAndCache(String key, int postId) async {
    final urls = await client.getDownloadUrls(postId);
    if (urls?.isUseful ?? false) {
      cache.set(key, urls!);
    }

    return urls;
  }
}
