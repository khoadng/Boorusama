// Project imports:
import '../../../tags/favorites/types.dart';
import '../merge_strategy.dart';

class FavoriteTagMergeStrategy extends MergeStrategy<FavoriteTag> {
  @override
  Object getUniqueId(FavoriteTag item) => item.name;

  @override
  Object getUniqueIdFromJson(Map<String, dynamic> json) =>
      json['name'] as String? ?? '';

  @override
  DateTime? getTimestamp(FavoriteTag item) => item.updatedAt ?? item.createdAt;

  @override
  FavoriteTag resolveConflict(FavoriteTag local, FavoriteTag remote) {
    final localTime = getTimestamp(local);
    final remoteTime = getTimestamp(remote);

    final newerTag = () {
      if (localTime == null && remoteTime == null) return local;
      if (localTime == null) return remote;
      if (remoteTime == null) return local;
      return remoteTime.isAfter(localTime) ? remote : local;
    }();

    final mergedLabels = _mergeLabels(local.labels, remote.labels);

    return newerTag.copyWith(
      labels: () => mergedLabels,
    );
  }

  List<String>? _mergeLabels(List<String>? local, List<String>? remote) {
    if (local == null && remote == null) return null;
    if (local == null) return remote;
    if (remote == null) return local;

    return {...local, ...remote}.toList();
  }
}
