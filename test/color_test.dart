import 'package:boorusama/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'hex',
    () {
      test(
        'Color to Hex',
        () => expect(Colors.red.hex, '#f44336'),
      );

      test(
        'Hex to Color',
        () => expect(ColorUtils.hexToColor('#F44336'), Color(Colors.red.value)),
      );
    },
  );
}
