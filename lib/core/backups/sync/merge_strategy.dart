// Project imports:
import 'types.dart';

abstract class MergeStrategy<T> {
  Object getUniqueId(T item);

  Object getUniqueIdFromJson(Map<String, dynamic> json);

  DateTime? getTimestamp(T item);

  MergeResult<T> merge(List<T> local, List<T> remote) {
    final localMap = <Object, T>{};
    for (final item in local) {
      localMap[getUniqueId(item)] = item;
    }

    var itemsMerged = 0;
    var itemsSkipped = 0;

    for (final remoteItem in remote) {
      final id = getUniqueId(remoteItem);
      final localItem = localMap[id];

      if (localItem == null) {
        localMap[id] = remoteItem;
        itemsMerged++;
      } else {
        final resolvedItem = resolveConflict(localItem, remoteItem);
        if (resolvedItem != localItem) {
          localMap[id] = resolvedItem;
          itemsMerged++;
        } else {
          itemsSkipped++;
        }
      }
    }

    return MergeResult(
      merged: localMap.values.toList(),
      stats: SyncStats(
        itemsReceived: remote.length,
        itemsMerged: itemsMerged,
        itemsSkipped: itemsSkipped,
      ),
    );
  }

  T resolveConflict(T local, T remote) {
    final localTime = getTimestamp(local);
    final remoteTime = getTimestamp(remote);

    if (localTime == null && remoteTime == null) return local;
    if (localTime == null) return remote;
    if (remoteTime == null) return local;

    return remoteTime.isAfter(localTime) ? remote : local;
  }
}

class KeepLocalStrategy<T> extends MergeStrategy<T> {
  KeepLocalStrategy({
    required this.getId,
    required this.getIdFromJson,
    this.getTime,
  });

  final Object Function(T item) getId;
  final Object Function(Map<String, dynamic> json) getIdFromJson;
  final DateTime? Function(T item)? getTime;

  @override
  Object getUniqueId(T item) => getId(item);

  @override
  Object getUniqueIdFromJson(Map<String, dynamic> json) => getIdFromJson(json);

  @override
  DateTime? getTimestamp(T item) => getTime?.call(item);

  @override
  T resolveConflict(T local, T remote) => local;
}
