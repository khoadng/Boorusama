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
    < 400 => 3,
    < 600 => 4,
    < 900 => 5,
    < 1200 => 6,
    < 1600 => 7,
    < 2000 => 8,
    < 2400 => 9,
    < 2800 => 10,
    _ => 11,
  };
}

int _getNormalGridColumns(double width) {
  return switch (width) {
    < 400 => 2,
    < 600 => 3,
    < 900 => 4,
    < 1200 => 5,
    < 1600 => 6,
    < 2000 => 7,
    < 2400 => 8,
    _ => 9,
  };
}

int _getLargeGridColumns(double width) {
  return switch (width) {
    < 400 => 1,
    < 600 => 2,
    < 900 => 3,
    < 1200 => 4,
    < 1600 => 5,
    < 2000 => 6,
    _ => 7,
  };
}
