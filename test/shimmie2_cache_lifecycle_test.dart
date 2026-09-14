import 'package:booru_clients/shimmie2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:boorusama/boorus/shimmie2/clients/providers.dart';
import 'package:boorusama/boorus/shimmie2/clients/cache.dart';
import 'package:boorusama/boorus/shimmie2/extensions/cache.dart';
import 'package:boorusama/boorus/shimmie2/extensions/providers.dart';
import 'package:boorusama/boorus/shimmie2/extensions/types.dart';

void main() {
  test(
    'GraphQL cache factory is lazy and disposed with its provider',
    () async {
      final factory = _RecordingGraphQLCacheFactory();
      final container = ProviderContainer(
        overrides: [
          shimmie2GraphQLCacheFactoryProvider.overrideWithValue(factory),
        ],
      );

      container.read(shimmie2GraphQLCacheProvider);
      expect(factory.created, 0);

      final cache = container.read(shimmie2GraphQLCacheProvider);
      await cache.set('key', 'value');
      expect(factory.created, 1);

      container.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(factory.disposed, 1);
    },
  );

  test(
    'extensions cache factory is lazy and disposed with its provider',
    () async {
      final factory = _RecordingExtensionsCacheFactory();
      final container = ProviderContainer(
        overrides: [
          shimmie2ExtensionsCacheFactoryProvider.overrideWithValue(factory),
        ],
      );

      container.read(shimmie2ExtensionsCacheProvider);
      expect(factory.created, 0);

      final cache = container.read(shimmie2ExtensionsCacheProvider);
      await cache.set(
        'key',
        const [
          Extension(
            name: 'GraphQL',
            description: 'test',
            category: 'test',
          ),
        ],
      );
      expect(factory.created, 1);

      container.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(factory.disposed, 1);
    },
  );
}

final class _RecordingGraphQLCacheFactory implements GraphQLCacheFactory {
  var created = 0;
  var disposed = 0;

  @override
  Future<GraphQLCache> create() async {
    created++;
    return InMemoryGraphQLCache();
  }

  @override
  Future<void> dispose(GraphQLCache cache) async => disposed++;
}

final class _RecordingExtensionsCacheFactory implements ExtensionsCacheFactory {
  var created = 0;
  var disposed = 0;

  @override
  Future<ExtensionsCache> create() async {
    created++;
    return _MemoryExtensionsCache();
  }

  @override
  Future<void> dispose(ExtensionsCache cache) async => disposed++;
}

final class _MemoryExtensionsCache implements ExtensionsCache {
  final values = <String, List<Extension>>{};
  final timestamps = <String, DateTime>{};

  @override
  Future<List<Extension>?> get(String key) async => values[key];

  @override
  Future<void> set(String key, List<Extension> extensions) async =>
      values[key] = extensions;

  @override
  Future<void> remove(String key) async {
    values.remove(key);
    timestamps.remove(key);
  }

  @override
  Future<void> clear() async {
    values.clear();
    timestamps.clear();
  }

  @override
  Future<DateTime?> getTimestamp(String key) async => timestamps[key];

  @override
  Future<void> setTimestamp(String key, DateTime timestamp) async =>
      timestamps[key] = timestamp;
}
