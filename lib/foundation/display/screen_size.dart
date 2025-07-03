// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'converter.dart';
import 'types.dart';

class Screen {
  const Screen._(this.context);

  factory Screen.of(BuildContext context) => Screen._(context);

  final BuildContext context;

  Size get _size => MediaQuery.sizeOf(context);

  ScreenSize get size => screenWidthToDisplaySize(_size.width);

  ScreenSize nextBreakpoint() => switch (size) {
        ScreenSize.small => ScreenSize.medium,
        ScreenSize.medium => ScreenSize.large,
        ScreenSize.large => ScreenSize.veryLarge,
        ScreenSize.veryLarge => ScreenSize.veryLarge
      };
}

extension ScreenSizeX on ScreenSize {
  bool get isLarge => this != ScreenSize.small;
}
