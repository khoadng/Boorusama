// In project exports:
export 'utils/string_utils.dart';

// External exports:
export 'package:recase/recase.dart';

// Package imports:
import 'package:basic_utils/basic_utils.dart' show StringUtils;

extension StringExtensions on String {
  String addCharAtPosition(
    String char,
    int position, {
    bool repeat = false,
  }) =>
      StringUtils.addCharAtPosition(
        this,
        char,
        position,
        repeat: repeat,
      );
}
