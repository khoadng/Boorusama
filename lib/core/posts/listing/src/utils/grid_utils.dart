// Dart imports:
import 'dart:math' as math;

// Project imports:
import '../../../../settings/settings.dart';

/// Calculates the number of columns to display based on available width and grid size.
///
/// Uses a non-linear growth function to gradually increase columns as width increases.
int calculateGridCount(double width, GridSize size) {
  return _calculateGridCount(
    width,
    switch (size) {
      GridSize.small => const GridParameters(
          baseColumns: 3,
          baseWidth: 400,
          columnWidthIncrement: 60,
          growthFactor: 0.65,
        ),
      GridSize.normal => const GridParameters(
          baseColumns: 2,
          baseWidth: 400,
          columnWidthIncrement: 70,
          growthFactor: 0.6,
        ),
      GridSize.large => const GridParameters(
          baseColumns: 1,
          baseWidth: 400,
          columnWidthIncrement: 140,
          growthFactor: 0.5,
        ),
    },
  );
}

int calculateGridCountFromParameters(double width, GridParameters parameters) {
  return _calculateGridCount(width, parameters);
}

/// Parameters that control grid column calculation.
class GridParameters {
  const GridParameters({
    required this.baseColumns,
    required this.baseWidth,
    required this.columnWidthIncrement,
    required this.growthFactor,
  });

  /// Minimum number of columns to display
  final int baseColumns;

  /// Width threshold before additional columns are added
  final double baseWidth;

  /// Width increment that would result in one additional column in linear model
  final double columnWidthIncrement;

  /// Exponent that controls column growth rate; lower values slow growth
  final double growthFactor;
}

/// Calculates grid columns using logarithmic growth to prevent excessive columns at large widths.
int _calculateGridCount(double width, GridParameters params) {
  if (width <= params.baseWidth) return params.baseColumns;

  final additionalColumnsLinear =
      (width - params.baseWidth) / params.columnWidthIncrement;

  final additionalColumns =
      math.pow(additionalColumnsLinear, params.growthFactor).floor();

  return params.baseColumns + additionalColumns;
}
