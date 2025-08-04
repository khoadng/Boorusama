// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'backup_data_source.dart';

class BackupRegistry {
  final Map<String, BackupDataSource> _sources = {};

  void register(BackupDataSource source) {
    _sources[source.id] = source;
  }

  List<BackupDataSource> getAllSources() {
    return _sources.values.sorted((a, b) => a.priority.compareTo(b.priority));
  }

  BackupDataSource? getSource(String id) {
    return _sources[id];
  }

  bool hasSource(String id) {
    return _sources.containsKey(id);
  }
}
