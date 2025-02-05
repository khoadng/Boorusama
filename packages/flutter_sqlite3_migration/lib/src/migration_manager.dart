import 'package:sqlite3/sqlite3.dart';

import 'exceptions.dart';
import 'migration.dart';
import 'migration_event.dart';

/// A manager class that handles SQLite database migrations.
///
/// This class manages database schema migrations by:
/// - Tracking migration history in a dedicated table
/// - Executing migrations in order
/// - Handling different migration modes (strict, repair, force)
/// - Providing progress notifications through listeners
class DbMigrationManager {
  DbMigrationManager._({
    required this.db,
    required this.targetVersion,
    required Map<int, void Function(Database)> migrations,
    required this.mode,
  }) : _migrations = migrations;

  /// Creates a new migration manager instance with validation.
  ///
  /// [db] The SQLite database instance to migrate
  /// [targetVersion] The desired final schema version
  /// [migrations] List of migrations to be applied
  /// [mode] Migration mode that controls validation behavior
  factory DbMigrationManager.create({
    required Database db,
    required int targetVersion,
    required List<Migration> migrations,
    MigrationMode mode = MigrationMode.strict,
  }) {
    // Check for duplicate versions
    final versionCounts = <int, int>{};
    for (final migration in migrations) {
      versionCounts[migration.version] =
          (versionCounts[migration.version] ?? 0) + 1;
    }

    final duplicateVersion = versionCounts.entries
        .where((e) => e.value > 1)
        .map((e) => e.key)
        .firstOrNull;
    if (duplicateVersion != null) {
      throw DuplicateMigrationVersionException(duplicateVersion);
    }

    final migrationMap = <int, MigrationCallback>{};
    for (final migration in migrations) {
      migrationMap[migration.version] = (db) {
        migration.up(MigrationContext(db));
      };
    }

    if (targetVersion < 0) {
      throw NegativeTargetVersionException(targetVersion);
    }

    final result = db.select('PRAGMA user_version');
    final currentVersion = result.first.columnAt(0) as int;
    final versions = migrations.map((e) => e.version).toList()..sort();

    if (migrations.isNotEmpty) {
      // Validate target version is valid
      if (!migrations.any((m) => m.version == targetVersion) &&
          targetVersion <= versions.last) {
        throw MissingRangeMigrationException(targetVersion);
      }
    }

    for (var i = 0; i < versions.length - 1; i++) {
      if (versions[i + 1] - versions[i] > 1) {
        throw NonSequentialMigrationException(versions[i], versions[i + 1]);
      }
    }

    if (versions.isNotEmpty) {
      final maxDefinedVersion = versions.last;

      if (currentVersion > maxDefinedVersion) {
        throw FutureMigrationVersionException(
          currentVersion,
          maxDefinedVersion,
        );
      }
    }

    final manager = DbMigrationManager._(
      db: db,
      targetVersion: targetVersion,
      migrations: migrationMap,
      mode: mode,
    )
      .._createMigrationHistoryTable() // Ensure the migration history table exists and is valid
      .._validateHistoryTable();

    return manager;
  }

  /// Name of the table storing migration history
  static const String kMigrationHistoryTable = 'migrations_history';

  /// The SQLite database instance being migrated
  final Database db;

  /// The target schema version to migrate to
  final int targetVersion;

  /// The migration mode controlling validation behavior
  final MigrationMode mode;

  final List<ProgressListener> _progressListeners = [];
  final Map<int, MigrationCallback> _migrations;

  /// Registers a listener for migration progress events
  void addProgressListener(MigrationProgressListener listener) {
    _progressListeners.add(listener);
  }

  void _notifyListeners(MigrationEvent event) {
    for (final listener in _progressListeners) {
      listener.onEvent(event);
    }
  }

  void _createMigrationHistoryTable() {
    db.execute('''
      CREATE TABLE IF NOT EXISTS $kMigrationHistoryTable (
        version INTEGER PRIMARY KEY,
        applied_at INTEGER NOT NULL,
        success INTEGER NOT NULL,
        error_message TEXT
      )
    ''');
  }

  void _validateHistoryTable() {
    try {
      // Check if table structure is valid
      final tableInfo = db.select(
        "PRAGMA table_info($kMigrationHistoryTable)",
      );

      final columns = tableInfo.map((row) => row['name'] as String).toSet();
      final requiredColumns = {
        'version',
        'applied_at',
        'success',
        'error_message',
      };

      if (!requiredColumns.every(columns.contains)) {
        // Table structure is invalid, recreate it
        db.execute('DROP TABLE IF EXISTS $kMigrationHistoryTable');
        _createMigrationHistoryTable();
      }

      // Validate data integrity
      final invalidRecords = db.select('''
        SELECT version FROM $kMigrationHistoryTable
        WHERE success NOT IN (0, 1)
        OR applied_at IS NULL
        OR version IS NULL
      ''');

      if (invalidRecords.isNotEmpty) {
        // Remove corrupted records
        db.execute('''
          DELETE FROM $kMigrationHistoryTable
          WHERE success NOT IN (0, 1)
          OR applied_at IS NULL
          OR version IS NULL
        ''');
      }
    } catch (e) {
      // Table is corrupted or has wrong schema, recreate it
      db.execute('DROP TABLE IF EXISTS $kMigrationHistoryTable');
      _createMigrationHistoryTable();
    }
  }

  void _logMigration(int version, {String? errorMessage}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    db.execute(
      '''
      INSERT INTO $kMigrationHistoryTable (version, applied_at, success, error_message)
      VALUES (?, ?, ?, ?)
      ''',
      [version, now, if (errorMessage == null) 1 else 0, errorMessage],
    );
  }

  /// Validates the current migration state.
  ///
  /// [currentVersion] Current schema version of the database
  ///
  /// Returns a [MigrationState] containing validation results
  MigrationState validateMigrationState({
    required int currentVersion,
  }) {
    final history = getMigrationHistory();
    final appliedVersions = history
        .where((h) => h['success'] == 1)
        .map((h) => h['version'] as int)
        .toList();

    final missingVersions = _migrations.keys
        .where((v) => v <= currentVersion && !appliedVersions.contains(v))
        .toList();

    return MigrationState(
      hasHistoryGap: missingVersions.isNotEmpty,
      hasVersionMismatch:
          appliedVersions.any((v) => !_migrations.containsKey(v)),
      missingVersions: missingVersions,
    );
  }

  /// Executes pending migrations to reach the target version.
  ///
  /// Migrations are run in a transaction and rolled back on failure.
  /// Progress events are emitted during execution.
  ///
  /// Throws various exceptions on validation or migration failures.
  void runMigrations() {
    if (_migrations.isEmpty) {
      // Nothing to do
      return;
    }

    final startTime = DateTime.now();
    final result = db.select('PRAGMA user_version');
    final currentVersion = result.first.columnAt(0) as int;

    final state = validateMigrationState(currentVersion: currentVersion);

    switch (mode) {
      case MigrationMode.strict:
        if (state.hasHistoryGap || state.hasVersionMismatch) {
          throw HistoryInconsistencyException(state.missingVersions);
        }

      case MigrationMode.repair:
        if (state.hasHistoryGap) {
          _repairMigrationHistory(state.missingVersions);
        }

      case MigrationMode.force:
        // Continue without validation
        break;
    }

    if (currentVersion < 0) {
      throw InvalidCurrentVersionException(currentVersion);
    }

    if (currentVersion < targetVersion) {
      var failedVersion = currentVersion;
      try {
        _notifyListeners(
          MigrationStartedEvent(
            fromVersion: currentVersion,
            targetVersion: targetVersion,
            totalSteps: targetVersion - currentVersion,
          ),
        );

        db.execute('BEGIN TRANSACTION');
        var step = 1;

        for (var v = currentVersion + 1; v <= targetVersion; v++) {
          failedVersion = v;
          final migration = _migrations[v];
          if (migration == null) {
            throw MissingMigrationException(v);
          }

          _notifyListeners(
            MigrationStepEvent(
              version: v,
              currentStep: step,
              totalSteps: targetVersion - currentVersion,
            ),
          );

          migration(db);
          step++;
        }

        db
          ..execute('PRAGMA user_version = $targetVersion')
          ..execute('COMMIT');

        _notifyListeners(
          MigrationCompletedEvent(
            finalVersion: targetVersion,
            duration: DateTime.now().difference(startTime),
          ),
        );

        for (var v = currentVersion + 1; v <= targetVersion; v++) {
          _logMigration(v);
        }
      } catch (error) {
        db.execute('ROLLBACK');
        _notifyListeners(
          MigrationFailedEvent(
            version: currentVersion,
            error: error.toString(),
          ),
        );

        _logMigration(failedVersion, errorMessage: error.toString());
        rethrow;
      }
    }
  }

  void _repairMigrationHistory(List<int> versions) {
    db.execute('BEGIN TRANSACTION');
    try {
      for (final version in versions) {
        _logMigration(version);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      throw RepairFailedException(e);
    }
  }

  /// Retrieves the complete migration history.
  ///
  /// Returns a list of maps containing version, timestamp and status info.
  List<Map<String, dynamic>> getMigrationHistory() {
    return db
        .select('SELECT * FROM $kMigrationHistoryTable ORDER BY version DESC')
        .map(Map<String, dynamic>.from)
        .toList();
  }
}
