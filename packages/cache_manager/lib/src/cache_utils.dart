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

  final lowerUrl = url.toLowerCase();

  // More flexible matching for Google favicons
  if (lowerUrl.contains('google.com') && lowerUrl.contains('favicons')) {
    return keyToMd5(url); // Use full URL since domain parameter matters
  }

  // Parse the URL and use only the path component for other URLs
  final uri = Uri.tryParse(url);
  return uri == null ? keyToMd5(url) : keyToMd5(uri.path);
}

String keyToMd5(String key) {
  final bytes = utf8.encode(key);
  final digest = md5.convert(bytes);
  return digest.toString();
}
