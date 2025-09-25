// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/foundation/caching/cache_size.dart';

void main() {
  group('CacheSize', () {
    test('tryParse from valid string formats', () {
      expect(CacheSize.tryParse('10mb')?.bytes, 10 * 1024 * 1024);
      expect(CacheSize.tryParse('1GB')?.bytes, 1024 * 1024 * 1024);
      expect(CacheSize.tryParse('2Gb')?.bytes, 2 * 1024 * 1024 * 1024);
      expect(CacheSize.tryParse('512KB')?.bytes, 512 * 1024);
      expect(CacheSize.tryParse('5 MB')?.bytes, 5 * 1024 * 1024);
    });

    test('tryParse unlimited string', () {
      expect(CacheSize.tryParse('unlimited')?.bytes, -1);
      expect(CacheSize.tryParse('UNLIMITED')?.bytes, -1);
      expect(CacheSize.tryParse('Unlimited')?.bytes, -1);
      expect(CacheSize.tryParse(' unlimited ')?.bytes, -1);
    });

    test('tryParse from int', () {
      expect(CacheSize.tryParse(10 * 1024 * 1024)?.bytes, 10 * 1024 * 1024);
      expect(CacheSize.tryParse(1000), null); // below minimum
      expect(CacheSize.tryParse(-1)?.bytes, -1); // unlimited
    });

    test('tryParse returns null for invalid input', () {
      expect(CacheSize.tryParse('invalid'), null);
      expect(CacheSize.tryParse(''), null);
      expect(CacheSize.tryParse(null), null);
    });

    test('unlimited constants and getters', () {
      expect(CacheSize.unlimited.bytes, -1);
      expect(CacheSize.unlimited.isUnlimited, true);
      expect(CacheSize.unlimited.isZero, false);
      expect(CacheSize.zero.isUnlimited, false);
      expect(CacheSize.oneGigabyte.isUnlimited, false);
    });

    test('displayString formats correctly', () {
      expect(CacheSize.zero.displayString(), '0B');
      expect(CacheSize.tryParse('10mb')?.displayString(), '10MB');
      expect(CacheSize.tryParse('1gb')?.displayString(), '1GB');
      expect(CacheSize.tryParse('1.5gb')?.displayString(), '1.5GB');
      expect(CacheSize.oneGigabyte.displayString(), '1GB');
      expect(CacheSize.unlimited.displayString(), 'unlimited');
    });

    test('displayString with space option', () {
      expect(CacheSize.oneGigabyte.displayString(), '1GB');
      expect(
        CacheSize.tryParse('512kb')?.displayString(withSpace: true),
        '512 KB',
      );
      expect(
        CacheSize.tryParse('1.5mb')?.displayString(withSpace: true),
        '1.5 MB',
      );
    });
  });
}
