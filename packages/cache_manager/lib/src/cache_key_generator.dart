import 'package:extended_image_library/extended_image_library.dart';

abstract class CacheKeyGenerator {
  String generateKey(String url, {String? customKey});
}

class DefaultCacheKeyGenerator implements CacheKeyGenerator {
  @override
  String generateKey(String url, {String? customKey}) {
    if (customKey != null) {
      return customKey;
    }

    try {
      if (url.toLowerCase().contains('google.com') &&
          url.toLowerCase().contains('favicons')) {
        return keyToMd5(url);
      }

      final uri = Uri.parse(url);
      return keyToMd5(uri.path);
    } catch (e) {
      return keyToMd5(url);
    }
  }
}
