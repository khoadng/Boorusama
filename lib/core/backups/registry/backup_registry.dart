// Dart imports:
import 'dart:io';

// Package imports:
import 'package:collection/collection.dart';
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

  Future<void> exportAll(String basePath) async {
    final sources = getAllSources();
    final timestamp = DateFormat('yyyy.MM.dd.HH.mm.ss').format(DateTime.now());
    final exportDir = Directory(join(basePath, 'backup_$timestamp'));

    if (!exportDir.existsSync()) {
      await exportDir.create(recursive: true);
    }

    for (final source in sources) {
      try {
        await source.exportToFile(
          join(exportDir.path, '${source.id}.json'),
        );
      } catch (e, st) {
        if (e is ExportError) {
          rethrow;
        }
        throw DataExportError(error: e, stackTrace: st);
      }
    }
  }

  Future<void> importAll(String basePath) async {
    final sources = getAllSources();

    for (final source in sources) {
      final filePath = join(basePath, '${source.id}.json');
      final file = File(filePath);

      if (file.existsSync()) {
        try {
          await source.importFromFile(filePath);
        } catch (e) {
          if (e is ImportError) {
            rethrow;
          }
          throw const ImportInvalidJson();
        }
      }
    }
  }
}
