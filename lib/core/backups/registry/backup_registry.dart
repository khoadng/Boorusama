// Dart imports:
import 'dart:io';

// Package imports:
import 'package:collection/collection.dart';
import 'package:foundation/foundation.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../foundation/path.dart';
import '../types.dart';
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

  Future<Either<ExportError, Unit>> exportAll(String basePath) async {
    final sources = getAllSources();
    final timestamp = DateFormat('yyyy.MM.dd.HH.mm.ss').format(DateTime.now());
    final exportDir = Directory(join(basePath, 'backup_$timestamp'));

    if (!exportDir.existsSync()) {
      await exportDir.create(recursive: true);
    }

    for (final source in sources) {
      final result = await source.exportToFile(
        join(exportDir.path, '${source.id}.json'),
      );

      if (result.isLeft()) {
        return result;
      }
    }

    return right(unit);
  }

  Future<Either<ImportError, Unit>> importAll(String basePath) async {
    final sources = getAllSources();

    for (final source in sources) {
      final filePath = join(basePath, '${source.id}.json');
      final file = File(filePath);

      if (file.existsSync()) {
        final result = await source.importFromFile(filePath);

        if (result.isLeft()) {
          return result;
        }
      }
    }

    return right(unit);
  }
}
