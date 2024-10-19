// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/foundation/filesize.dart';

abstract class S {
  static const int kb = 1024;
  static const int mb = kb * 1024;
  static const int gb = mb * 1024;
  static const int tb = gb * 1024;
  static const int pb = tb * 1024;
  static const int eb = pb * 1024;
}

void main() {
  test('Handles null input', () {
    expect(Filesize.tryParse(null), null);
  });

  test('Handles negative input', () {
    expect(Filesize.tryParse(-1), null);
  });

  test('Handles zero input', () {
    expect(Filesize.tryParse(0), '0 B');
  });

  test('Handles just under a kilobyte', () {
    expect(Filesize.tryParse(S.kb - 1), '1023 B');
  });

  test('Handles exactly one kilobyte', () {
    expect(Filesize.tryParse(S.kb), '1.00 KB');
  });

  test('Handles just over a kilobyte', () {
    expect(Filesize.tryParse(S.kb + 1), '1.00 KB');
  });

  test('Handles exactly one megabyte', () {
    expect(Filesize.tryParse(S.mb), '1.00 MB');
  });

  test('Handles just over a megabyte', () {
    expect(Filesize.tryParse(S.mb + 1), '1.00 MB');
  });

  test('Handles exactly one gigabyte', () {
    expect(Filesize.tryParse(S.gb), '1.00 GB');
  });

  test('Handles exactly one petabyte', () {
    expect(Filesize.tryParse(S.pb), '1.00 PB');
  });

  test('Handles exactly one exabyte', () {
    expect(Filesize.tryParse(S.eb), '1.00 EB');
  });

  test('Handles custom rounding', () {
    expect(
      Filesize.tryParse(S.kb + 1, round: 3),
      '1.001 KB',
    );
    expect(
      Filesize.tryParse(S.mb + 1, round: 4),
      '1.0000 MB',
    );
  });

  test('Handles large file sizes without overflow', () {
    expect(Filesize.tryParse(9223372036854775807),
        '8.00 EB'); // Max 64-bit integer
  });

  test('Handles custom units', () {
    expect(
      Filesize.tryParse(
        S.kb,
        options: FilesizeOptions().copyWith(
          unitBuilder: (idx) => switch (idx) {
            0 => 'X',
            1 => 'Y',
            _ => 'Z',
          },
        ),
      ),
      '1.00 Y',
    );
  });

  test('Handles custom formatting', () {
    expect(
      Filesize.tryParse(
        S.kb,
        round: 0,
        options: FilesizeOptions().copyWith(
          formatter: (size, unit) => '$size$unit',
        ),
      ),
      '1KB',
    );
  });

  test('Handles custom dividers', () {
    expect(
      Filesize.tryParse(
        1000 * 1000,
        options: FilesizeOptions.custom(divider: 1000),
      ),
      '1.00 MB',
    );
  });
}
