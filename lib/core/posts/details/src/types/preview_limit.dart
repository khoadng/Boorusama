sealed class PreviewLimit {
  const PreviewLimit();
}

class LimitedPreview extends PreviewLimit {
  const LimitedPreview(this.rows);

  const LimitedPreview.defaults() : rows = 4;

  final int rows;

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
