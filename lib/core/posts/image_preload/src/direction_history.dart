// Package imports:
import 'package:clock/clock.dart';

// Project imports:
import 'types.dart';

class DirectionHistory {
  DirectionHistory({
    this.options = const DirectionHistoryOptions(),
    Clock? clock,
  }) : _clock = clock ?? const Clock();

  factory DirectionHistory.fromDirections(
    List<int> directions, {
    DirectionHistoryOptions? options,
    Clock? clock,
  }) {
    final history = DirectionHistory(
      options: options ?? const DirectionHistoryOptions(),
      clock: clock,
    );
    final baseTime = history._clock.now().millisecondsSinceEpoch;
    for (var i = 0; i < directions.length; i++) {
      history._directions.add((directions[i], baseTime + (i * 100)));
    }

    if (history._directions.length > history.options.maxHistorySize) {
      final removeCount =
          history._directions.length - history.options.maxHistorySize;
      history._directions.removeRange(0, removeCount);
    }
    return history;
  }

  final DirectionHistoryOptions options;
  final Clock _clock;
  final List<(int dir, int timestampMs)> _directions = [];

  List<(int, int)> get directions => List.unmodifiable(_directions);

  void addDirection(int currentPage, int? lastPage) {
    if (lastPage == null || currentPage == lastPage) return;

    final direction = switch (currentPage.compareTo(lastPage)) {
      > 0 => 1, // Forward
      < 0 => -1, // Backward
      _ => 0, // Same (shouldn't happen due to guard above)
    };

    final nowMs = _clock.now().millisecondsSinceEpoch;
    _directions.add((direction, nowMs));

    if (_directions.length > options.maxHistorySize) {
      _directions.removeAt(0);
    }
  }

  void clear() {
    _directions.clear();
  }

  ScrollDirection get scrollDirection => ScrollDirection.fromDirectionHistory(
    _directions.map((e) => e.$1).toList(),
    options,
    scrollSpeed: getScrollSpeed(),
  );

  DirectionConfidence get confidence =>
      DirectionConfidence.fromDirectionHistory(
        _directions.map((e) => e.$1).toList(),
        scrollDirection,
        options,
        scrollSpeed: getScrollSpeed(),
      );

  /// Get scroll speed based on recent movement frequency
  ScrollSpeed getScrollSpeed() {
    if (_directions.length < 2) return ScrollSpeed.normal;

    final recent = _directions.length > 5
        ? _directions.sublist(_directions.length - 5)
        : _directions;
    final totalTimeMs = recent.last.$2 - recent.first.$2;
    final totalTimeSec = totalTimeMs / 1000.0;
    final pagesMoved = recent.fold<int>(0, (sum, e) => sum + e.$1.abs());

    final speed = totalTimeSec > 0
        ? pagesMoved / totalTimeSec
        : double.infinity;

    return switch (speed) {
      < 0.2 => ScrollSpeed.crawling,
      < 0.5 => ScrollSpeed.slow,
      < 1.0 => ScrollSpeed.normal,
      < 2.0 => ScrollSpeed.fast,
      < 5.0 => ScrollSpeed.rapid,
      _ => ScrollSpeed.blazing,
    };
  }

  /// Determine entry pattern based on navigation history
  EntryPattern get entryPattern {
    final dirList = _directions.map((e) => e.$1).toList();
    return switch (dirList.length) {
      0 => EntryPattern.direct, // Just arrived, no movement yet
      1 => EntryPattern.initial, // First move from entry point
      _ when _isConsistentDirection(dirList) => EntryPattern.sequential,
      _ => EntryPattern.exploring,
    };
  }

  bool _isConsistentDirection(List<int> dirList) {
    if (dirList.length < 3) return false;
    final recent = dirList.take(3);
    return recent.every((d) => d == recent.first);
  }
}
