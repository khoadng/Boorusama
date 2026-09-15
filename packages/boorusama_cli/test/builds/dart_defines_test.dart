import 'package:boorusama_cli/src/builds/dart_defines.dart';
import 'package:test/test.dart';

void main() {
  group('DartDefines.buildTimestamp', () {
    test('uses SOURCE_DATE_EPOCH when set', () {
      final timestamp = DartDefines.buildTimestamp(
        environment: const {'SOURCE_DATE_EPOCH': '1234567890'},
      );

      expect(timestamp, DateTime.utc(2009, 2, 13, 23, 31, 30));
    });

    test('uses current time when SOURCE_DATE_EPOCH is absent', () {
      final expected = DateTime.utc(2026, 1, 2, 3, 4, 5);

      expect(
        DartDefines.buildTimestamp(environment: const {}, now: () => expected),
        expected,
      );
    });

    test('rejects invalid SOURCE_DATE_EPOCH', () {
      expect(
        () => DartDefines.buildTimestamp(
          environment: const {'SOURCE_DATE_EPOCH': 'invalid'},
        ),
        throwsFormatException,
      );
    });
  });
}
