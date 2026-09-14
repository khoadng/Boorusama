// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:boorusama/core/themes/colors/types.dart';

void main() {
  group(
    'hex',
    () {
      test(
        'Color to Hex',
        () => expect(Colors.red.hexWithoutAlpha, '#f44336'),
      );

      test(
        'Hex to Color',
        () => expect(
          ColorUtils.hexToColor('#F44336'),
          Color(LegacyColor(Colors.red).value),
        ),
      );
    },
  );
}
