// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:version/version.dart';

// Project imports:
import 'package:boorusama/foundation/version.dart';

void main() {
  group('significant version test', () {
    test(
      '1.0.0 significantly lower than 2.0.0',
      () => expect(
        Version(1, 0, 0).significantlyLowerThan(Version(2, 0, 0)),
        true,
      ),
    );

    test(
      '1.0.0 significantly lower than 1.1.0',
      () => expect(
        Version(1, 0, 0).significantlyLowerThan(Version(1, 1, 0)),
        true,
      ),
    );

    test(
      '1.0.1 not significantly lower than 1.0.0',
      () => expect(
        Version(1, 0, 1).significantlyLowerThan(Version(1, 0, 0)),
        false,
      ),
    );

    test(
      '1.0.0 not significantly lower than 1.0.0',
      () => expect(
        Version(1, 0, 0).significantlyLowerThan(Version(1, 0, 0)),
        false,
      ),
    );

    // null cases
    group('null cases', () {
      test(
        'null not significantly lower than 1.0.0',
        () => expect(
          null.significantlyLowerThan(Version(1, 0, 0)),
          false,
        ),
      );

      test(
        '1.0.0 not significantly lower than null',
        () => expect(
          Version(1, 0, 0).significantlyLowerThan(null),
          false,
        ),
      );

      test(
        'null not significantly lower than null',
        () => expect(
          null.significantlyLowerThan(null),
          false,
        ),
      );
    });
  });
}
