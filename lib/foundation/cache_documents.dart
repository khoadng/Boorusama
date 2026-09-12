import 'package:flutter/services.dart';

enum CacheDocumentKind { images, videos }

abstract final class CacheDocuments {
  static const _channel = MethodChannel('cache_documents');

  static Future<void> open(
    CacheDocumentKind kind, {
    required String imagesLabel,
    required String videosLabel,
  }) => _channel.invokeMethod<void>('openCache', {
    'kind': kind.name,
    'imagesLabel': imagesLabel,
    'videosLabel': videosLabel,
  });
}
