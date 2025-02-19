// Dart imports:
import 'dart:io';

// Package imports:
import 'package:path/path.dart' show join;
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import '../foundation/loggers/logger.dart';

mixin DatabaseUtilsMixin {
  Database get db;

  void transaction(void Function() action) {
    db.execute('BEGIN TRANSACTION');
    try {
      action();
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }
}

Future<Database?> createDb({
  required String folderPath,
  required String name,
  Logger? logger,
}) async {
  try {
    // Make sure the directory exists
    await Directory(folderPath).create(recursive: true);

    return sqlite3.open(join(folderPath, name));
  } on Exception catch (e) {
    logger?.logE(
      name,
      'Failed to initialize SQLite database: $e',
    );
    return null;
  }
}
