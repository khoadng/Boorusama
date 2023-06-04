// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/caching/fifo_cacher.dart';

void main() {
  test(
    'get a cached item should return cached value',
    () {
      const key = 'foo';
      const value = 'bar';
      final cacher = FifoCacher<String, String>()..put(key, value);

      expect(cacher.get(key), value);
    },
  );

  test(
    'get a non-existed item should return null',
    () {
      final cacher = FifoCacher<String, String>();

      expect(cacher.get('a'), isNull);
    },
  );

  test(
    'clear cache should clear all cached items',
    () {
      const key = 'foo';
      const value = 'bar';
      const key2 = 'foo2';
      const value2 = 'bar2';
      final cacher = FifoCacher<String, String>()
        ..put(key, value)
        ..put(key2, value2)
        ..clear();

      expect(cacher.get(key), isNull);
      expect(cacher.get(key2), isNull);
    },
  );

  test(
    'cache item existence check should be successful when there is a item in cache',
    () {
      const key = 'foo';
      const value = 'bar';
      final cacher = FifoCacher<String, String>()..put(key, value);

      expect(cacher.exist(key), true);
    },
  );

  test(
    'cache item existence check should fail when there is no equivalent item in cache',
    () {
      const key = 'foo';
      const value = 'bar';
      final cacher = FifoCacher<String, String>()..put(key, value);

      expect(cacher.exist('bar'), false);
    },
  );

  test(
    'when at max capacity, adding a new item will invalidate the first item',
    () {
      const key = 'foo';
      const value = 'bar';
      const key2 = 'foo2';
      const value2 = 'bar2';
      const key3 = 'foo3';
      const value3 = 'bar3';
      final cacher = FifoCacher<String, String>(
        capacity: 2,
      )
        ..put(key, value)
        ..put(key2, value2)
        ..put(key3, value3);

      expect(cacher.get(key), isNull);
      expect(cacher.get(key2), value2);
      expect(cacher.get(key3), value3);
    },
  );
}
