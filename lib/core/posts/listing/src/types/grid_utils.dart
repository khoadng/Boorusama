// Project imports:
import 'grid_size.dart';

// the smaller the grid size, the larger the cache extent so that more items can be preloaded
double calculateCacheExtentFactor(GridSize size) => switch (size) {
  GridSize.micro => 2.0,
  GridSize.tiny => 1.6,
  GridSize.small => 1.2,
  GridSize.normal => 1,
  GridSize.large => 0.8,
};

int calculateGridCount(double? width, GridSize size) {
  if (width == null) {
    return switch (size) {
      GridSize.micro => 5,
      GridSize.tiny => 4,
      GridSize.small => 3,
      GridSize.normal => 2,
      GridSize.large => 1,
    };
  }

  return switch (size) {
    GridSize.micro => _getMicroGridColumns(width),
    GridSize.tiny => _getTinyGridColumns(width),
    GridSize.small => _getSmallGridColumns(width),
    GridSize.normal => _getNormalGridColumns(width),
    GridSize.large => _getLargeGridColumns(width),
  };
}

int _getMicroGridColumns(double width) {
  return switch (width) {
    < 500 => 5,
    < 600 => 6,
    < 700 => 7,
    < 800 => 8,
    < 1000 => 9,
    < 1200 => 10,
    < 1400 => 11,
    < 1600 => 12,
    < 2000 => 13,
    < 2400 => 14,
    < 2800 => 15,
    _ => 16,
  };
}

int _getTinyGridColumns(double width) {
  return switch (width) {
    < 500 => 4,
    < 600 => 5,
    < 700 => 6,
    < 800 => 7,
    < 1000 => 8,
    < 1200 => 9,
    < 1400 => 10,
    < 1600 => 11,
    < 2000 => 12,
    < 2400 => 13,
    < 2800 => 14,
    _ => 15,
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
