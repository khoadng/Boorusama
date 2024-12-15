// Project imports:
import '../../../foundation/display.dart';
import '../../../settings/settings.dart';

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
