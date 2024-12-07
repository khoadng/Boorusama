// Project imports:
import 'package:boorusama/core/settings.dart';
import 'types.dart';

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
