// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/foundation/display_mode.dart';

void main() {
  group('DisplayModeService', () {
    test('requests high refresh rate on supported platforms', () async {
      var requested = false;
      final service = DisplayModeService(
        isSupportedPlatform: () => true,
        setHighRefreshRate: () async {
          requested = true;
        },
      );

      await service.preferHighRefreshRate();

      expect(requested, isTrue);
    });

    test('does nothing on unsupported platforms', () async {
      var requested = false;
      final service = DisplayModeService(
        isSupportedPlatform: () => false,
        setHighRefreshRate: () async {
          requested = true;
        },
      );

      await service.preferHighRefreshRate();

      expect(requested, isFalse);
    });

    test('swallows display mode failures', () async {
      final service = DisplayModeService(
        isSupportedPlatform: () => true,
        setHighRefreshRate: () => Future<void>.error(
          StateError('unsupported'),
        ),
      );

      await expectLater(
        service.preferHighRefreshRate(),
        completes,
      );
    });
  });
}
