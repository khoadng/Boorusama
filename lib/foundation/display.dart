// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:boorusama/core/feats/settings/settings.dart';

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

int displaySizeToGridCountWeight(ScreenSize size) => switch (size) {
      ScreenSize.small => 1,
      ScreenSize.medium => 2,
      ScreenSize.large => 3,
      ScreenSize.veryLarge => 4,
    };

int calculateGridCount(double width, GridSize size) {
  final displaySize = screenWidthToDisplaySize(width);
  final weight = displaySizeToGridCountWeight(displaySize);

  final count = switch (size) {
    GridSize.small => 2.5 * weight,
    GridSize.normal => 1.5 * weight,
    GridSize.large => 1 * weight,
  };

  return count.round();
}

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

extension DisplayX on BuildContext {
  Screen get screen => Screen.of(this);
  Orientation get orientation => MediaQuery.orientationOf(this);
}

extension OrientationX on Orientation {
  bool get isLandscape => this == Orientation.landscape;
  bool get isPortrait => this == Orientation.portrait;
}
