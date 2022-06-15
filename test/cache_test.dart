// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/infrastructure/caching/default_cacher.dart';

class TestClock {
  DateTime current = DateTime.now();

  // ignore: use_setters_to_change_properties
  void setTime(DateTime time) => current = time;
  DateTime getTime() => current;
}

void main() {
  test(
    'cache get immediately should return cached value',
    () {
      const key = 'foo';
      const value = 'bar';
      final cacher = DefaultCacher<String>(
        currentTimeBuilder: () => DateTime(2017, 1, 1, 17, 30),
      )..put(key, value, const Duration(minutes: 1));

      final actual = cacher.get(key);

      expect(actual, value);
    },
  );

  test(
    'cache get when almost staled should return cached value',
    () {
      const key = 'foo';
      const value = 'bar';
      final clock = TestClock()..setTime(DateTime(2017, 1, 1, 17, 31));
      final cacher = DefaultCacher<String>(
        currentTimeBuilder: clock.getTime,
      )..put(key, value, const Duration(minutes: 1));

      clock.setTime(DateTime(2017, 1, 1, 17, 31, 59));

      final actual = cacher.get(key);

      expect(actual, value);
    },
  );

  test(
    'cache get when staled should return null',
    () {
      const key = 'foo';
      const value = 'bar';
      final clock = TestClock()..setTime(DateTime(2017, 1, 1, 17, 31));
      final cacher = DefaultCacher<String>(
        currentTimeBuilder: clock.getTime,
      )..put(key, value, const Duration(minutes: 1));

      clock.setTime(DateTime(2017, 1, 1, 17, 32, 1));

      final actual = cacher.get(key);

      expect(actual, isNull);
    },
  );
}
