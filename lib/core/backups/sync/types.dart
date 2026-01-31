// Package imports:
import 'package:equatable/equatable.dart';

class SyncStats extends Equatable {
  const SyncStats({
    required this.itemsReceived,
    required this.itemsMerged,
    required this.itemsSkipped,
  });

  const SyncStats.empty()
    : itemsReceived = 0,
      itemsMerged = 0,
      itemsSkipped = 0;

  final int itemsReceived;
  final int itemsMerged;
  final int itemsSkipped;

  SyncStats operator +(SyncStats other) => SyncStats(
    itemsReceived: itemsReceived + other.itemsReceived,
    itemsMerged: itemsMerged + other.itemsMerged,
    itemsSkipped: itemsSkipped + other.itemsSkipped,
  );

  @override
  List<Object?> get props => [itemsReceived, itemsMerged, itemsSkipped];
}

class MergeResult<T> extends Equatable {
  const MergeResult({
    required this.merged,
    required this.stats,
  });

  final List<T> merged;
  final SyncStats stats;

  @override
  List<Object?> get props => [merged, stats];
}
