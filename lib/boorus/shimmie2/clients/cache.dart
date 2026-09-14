// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../shared/cache_mixin.dart';

abstract interface class GraphQLCacheFactory {
  Future<GraphQLCache> create();

  Future<void> dispose(GraphQLCache cache);
}

final class HiveGraphQLCacheFactory implements GraphQLCacheFactory {
  const HiveGraphQLCacheFactory();

  @override
  Future<GraphQLCache> create() async =>
      GraphQLCacheHive(await Hive.openBox('shimmie2_graphql_cache'));

  @override
  Future<void> dispose(GraphQLCache cache) async {
    if (cache case final GraphQLCacheHive hiveCache) {
      await hiveCache.box.close();
    }
  }
}

class GraphQLCacheHive with Shimmie2CacheMixin implements GraphQLCache {
  GraphQLCacheHive(this.box);

  @override
  final Box box;

  @override
  Future<T?> get<T>(String key) async {
    final value = box.get(key);

    if (value == null) return null;

    return switch ((T, value)) {
      (const (Set<String>), final String jsonStr) =>
        _decodeStringSet(jsonStr) as T?,
      (_, final T typedValue) => typedValue,
      _ => null,
    };
  }

  Set<String>? _decodeStringSet(String jsonStr) {
    try {
      return switch (jsonDecode(jsonStr)) {
        final List list => list.whereType<String>().toSet(),
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> set<T>(String key, T value) async {
    final encoded = switch (value) {
      final Set<String> set => jsonEncode(set.toList()),
      _ => value,
    };
    await box.put(key, encoded);
  }
}
