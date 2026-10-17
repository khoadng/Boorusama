// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/foundation/plugin_app_file_picker.dart';

void main() {
  final cases = [
    (
      picked: '/storage/raw//storage/emulated/0/Download',
      existing: <String>{},
      expected: '/storage/emulated/0/Download',
    ),
    (
      picked: '/storage/raw//storage/emulated/0/Download/backups',
      existing: <String>{},
      expected: '/storage/emulated/0/Download/backups',
    ),
    (
      picked: '/storage/emulated/0/downloads',
      existing: <String>{},
      expected: '/storage/emulated/0/Download',
    ),
    (
      picked: '/storage/emulated/0/downloads',
      existing: {'/storage/emulated/0/downloads'},
      expected: '/storage/emulated/0/downloads',
    ),
    (
      picked: '/storage/emulated/0/Pictures/boorusama',
      existing: <String>{},
      expected: '/storage/emulated/0/Pictures/boorusama',
    ),
    (
      picked: '/storage/1A2B-3C4D/Download',
      existing: <String>{},
      expected: '/storage/1A2B-3C4D/Download',
    ),
  ];

  for (final c in cases) {
    test('a picked folder of ${c.picked} resolves to ${c.expected}', () {
      expect(
        repairPickedDirectory(c.picked, exists: c.existing.contains),
        c.expected,
      );
    });
  }
}
