// Flutter imports:
import 'package:flutter/cupertino.dart';

enum ScreenSize {
  small,
  medium,
  large,
  veryLarge,
}

ScreenSize screenWidthToDisplaySize(double width) {
  if (width <= 600) {
    return ScreenSize.small;
  } else if (width <= 1100) {
    return ScreenSize.medium;
  } else if (width <= 1400) {
    return ScreenSize.large;
  } else {
    return ScreenSize.veryLarge;
  }
}

class Screen {
  const Screen._(this.context);

  factory Screen.of(BuildContext context) => Screen._(context);

  final BuildContext context;

  Size get _size => MediaQuery.of(context).size;

  ScreenSize get size => screenWidthToDisplaySize(_size.width);
}
