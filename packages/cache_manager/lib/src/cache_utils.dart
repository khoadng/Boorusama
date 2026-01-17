import 'dart:convert';

import 'package:crypto/crypto.dart';

String generateCacheKey(
  String url, {
  String? customKey,
  required String Function(String) keyToMd5,
}) {
  if (customKey != null) {
    return customKey;
  }

  final uri = Uri.tryParse(url);
  if (uri == null) {
    return keyToMd5(url);
  }

  // Use path + query for cache key since query params can affect content
  final pathWithQuery = uri.query.isEmpty
      ? uri.path
      : '${uri.path}?${uri.query}';

  return keyToMd5(pathWithQuery);
}

String keyToMd5(String key) {
  final bytes = utf8.encode(key);
  final digest = md5.convert(bytes);
  return digest.toString();
}
