// Project imports:
import '../../../../settings/settings.dart';

int calculateGridCount(double width, GridSize size) {
  return switch (size) {
    GridSize.small => _getSmallGridColumns(width),
    GridSize.normal => _getNormalGridColumns(width),
    GridSize.large => _getLargeGridColumns(width),
  };
}

int _getSmallGridColumns(double width) {
  return switch (width) {
    < 500 => 3,
    < 600 => 4,
    < 700 => 5,
    < 800 => 6,
    < 1000 => 7,
    < 1200 => 8,
    < 1400 => 9,
    < 1600 => 10,
    < 2000 => 11,
    < 2400 => 12,
    < 2800 => 13,
    _ => 14,
  };
}

int _getNormalGridColumns(double width) {
  return switch (width) {
    < 500 => 2,
    < 600 => 3,
    < 700 => 4,
    < 950 => 5,
    < 1300 => 6,
    < 1650 => 7,
    < 2000 => 8,
    < 2350 => 9,
    < 2700 => 10,
    _ => 11,
  };
}

int _getLargeGridColumns(double width) {
  return switch (width) {
    < 500 => 1,
    < 700 => 2,
    < 900 => 3,
    < 1400 => 4,
    < 1900 => 5,
    < 2400 => 6,
    < 2900 => 7,
    _ => 8,
  };
}
