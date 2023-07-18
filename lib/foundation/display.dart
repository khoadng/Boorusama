// Flutter imports:
import 'package:flutter/cupertino.dart';

enum ScreenSize {
  small,
  medium,
  large,
  veryLarge,
}

ScreenSize screenWidthToDisplaySize(double width) => switch (width) {
      <= 600 => ScreenSize.small,
      <= 1100 => ScreenSize.medium,
      <= 1500 => ScreenSize.large,
      _ => ScreenSize.veryLarge,
    };

class Screen {
  const Screen._(this.context);

  factory Screen.of(BuildContext context) => Screen._(context);

  final BuildContext context;

  Size get _size => MediaQuery.of(context).size;

  ScreenSize get size => screenWidthToDisplaySize(_size.width);

  ScreenSize nextBreakpoint() {
    switch (size) {
      case ScreenSize.small:
        return ScreenSize.medium;
      case ScreenSize.medium:
        return ScreenSize.large;
      case ScreenSize.large:
        return ScreenSize.veryLarge;
      case ScreenSize.veryLarge:
        return ScreenSize.veryLarge;
    }
  }
}
