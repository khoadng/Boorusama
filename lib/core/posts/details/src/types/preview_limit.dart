sealed class PreviewLimit {
  const PreviewLimit();
}

class LimitedPreview extends PreviewLimit {
  const LimitedPreview(
    this.rows, {
    this.baseRowsPerExpansion = 4,
    this.progressiveMultiplier = 1.0,
  });

  const LimitedPreview.progressive()
    : rows = 4,
      baseRowsPerExpansion = 4,
      progressiveMultiplier = 1.5;

  final int rows;
  final int baseRowsPerExpansion;
  final double progressiveMultiplier;

  PreviewGridState calculateState({
    required int totalCount,
    required int crossAxisCount,
    required bool isExpanded,
  }) {
    final itemLimit = rows * crossAxisCount;
    final hasMore = totalCount > itemLimit;
    final displayCount = isExpanded ? totalCount : itemLimit;

    return PreviewGridState(
      displayCount: hasMore ? displayCount : totalCount,
      hasMore: hasMore,
      hiddenCount: hasMore ? totalCount - itemLimit : 0,
    );
  }

  int? calculateProgressiveLimit({
    required int totalCount,
    required int expandCount,
    required int crossAxisCount,
  }) {
    final initialLimit = rows * crossAxisCount;
    var currentLimit = initialLimit;

    var rowsToAdd = baseRowsPerExpansion;
    for (var i = 0; i < expandCount; i++) {
      currentLimit += rowsToAdd * crossAxisCount;
      rowsToAdd = (rowsToAdd * progressiveMultiplier).round();
    }

    if (currentLimit >= totalCount) return null;
    return currentLimit;
  }
}

class UnlimitedPreview extends PreviewLimit {
  const UnlimitedPreview();
}

class PreviewGridState {
  const PreviewGridState({
    required this.displayCount,
    required this.hasMore,
    required this.hiddenCount,
  });

  final int displayCount;
  final bool hasMore;
  final int hiddenCount;
}
