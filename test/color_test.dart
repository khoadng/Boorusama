// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/foundation/utils/color_utils.dart';

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
