// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../shared/cache_mixin.dart';
import 'types.dart';

abstract class ExtensionsCache {
  Future<List<Extension>?> get(String key);
  Future<void> set(String key, List<Extension> extensions);
  Future<void> remove(String key);
  Future<void> clear();
  Future<DateTime?> getTimestamp(String key);
  Future<void> setTimestamp(String key, DateTime timestamp);
}

class LazyExtensionsCache implements ExtensionsCache {
  LazyExtensionsCache(Future<ExtensionsCache> Function() cacheFactory)
    : _lazyCache = LazyAsync(cacheFactory);

  final LazyAsync<ExtensionsCache> _lazyCache;

  @override
  Future<List<Extension>?> get(String key) async {
    final cache = await _lazyCache();
    return cache.get(key);
  }

  @override
  Future<void> set(String key, List<Extension> extensions) async {
    final cache = await _lazyCache();
    return cache.set(key, extensions);
  }

  @override
  Future<void> remove(String key) async {
    final cache = await _lazyCache();
    return cache.remove(key);
  }

  @override
  Future<void> clear() async {
    final cache = await _lazyCache();
    return cache.clear();
  }

  @override
  Future<DateTime?> getTimestamp(String key) async {
    final cache = await _lazyCache();
    return cache.getTimestamp(key);
  }

  @override
  Future<void> setTimestamp(String key, DateTime timestamp) async {
    final cache = await _lazyCache();
    return cache.setTimestamp(key, timestamp);
  }
}

class ExtensionsCacheHive with Shimmie2CacheMixin implements ExtensionsCache {
  ExtensionsCacheHive(this.box);

  @override
  final Box box;

  @override
  Future<List<Extension>?> get(String key) async {
    final value = box.get(key);

    if (value == null) return null;

    return switch (value) {
      final String jsonStr => _decodeExtensions(jsonStr),
      _ => null,
    };
  }

  List<Extension>? _decodeExtensions(String jsonStr) {
    try {
      return switch (jsonDecode(jsonStr)) {
        final List list =>
          list
              .map(
                (item) => switch (item) {
                  final Map<String, dynamic> map => Extension.fromJson(map),
                  _ => null,
                },
              )
              .whereType<Extension>()
              .toList(),
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> set(String key, List<Extension> extensions) async {
    final encoded = jsonEncode(extensions.map((e) => e.toJson()).toList());
    await box.put(key, encoded);
  }
}
