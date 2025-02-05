import 'package:flutter_sqlite3_migration/src/exceptions.dart';
import 'package:flutter_sqlite3_migration/src/migration.dart';
import 'package:flutter_sqlite3_migration/src/migration_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('history', () {
    late Database db;

    setUp(() {
      db = sqlite3.openInMemory();
    });

    tearDown(() {
      db.dispose();
    });

    test('creates migration history table', () {
      DbMigrationManager.create(
        db: db,
        targetVersion: 1,
        migrations: [
          BasicMigration(version: 1, onUp: (context) {}),
        ],
      ).runMigrations();

      final tables = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [DbMigrationManager.kMigrationHistoryTable],
      );
      expect(tables, isNotEmpty);
    });

    test('logs successful migrations', () {
      final manager = DbMigrationManager.create(
        db: db,
        targetVersion: 2,
        migrations: [
          BasicMigration(
            version: 1,
            onUp: (context) {
              context.execute('CREATE TABLE test1 (id INTEGER PRIMARY KEY)');
            },
          ),
          BasicMigration(
            version: 2,
            onUp: (context) {
              context.execute('CREATE TABLE test2 (id INTEGER PRIMARY KEY)');
            },
          ),
        ],
      )..runMigrations();

      final history = manager.getMigrationHistory();
      expect(history.length, equals(2));
      expect(history[0]['version'], equals(2));
      expect(history[0]['success'], equals(1));
      expect(history[0]['error_message'], isNull);
      expect(history[1]['version'], equals(1));
      expect(history[1]['success'], equals(1));
    });

    test('logs failed migrations', () {
      final manager = DbMigrationManager.create(
        db: db,
        targetVersion: 2,
        migrations: [
          BasicMigration(
            version: 1,
            onUp: (context) {
              context.execute('CREATE TABLE test1 (id INTEGER PRIMARY KEY)');
            },
          ),
          BasicMigration(
            version: 2,
            onUp: (context) {
              context.execute('Invalid SQL');
            },
          ),
        ],
      );

      expect(manager.runMigrations, throwsException);

      final history = manager.getMigrationHistory();
      expect(history.length, equals(1));
      expect(history[0]['version'], equals(2));
      expect(history[0]['success'], equals(0));
      expect(history[0]['error_message'], isNotNull);
    });

    test('preserves history after rollback', () {
      final manager = DbMigrationManager.create(
        db: db,
        targetVersion: 2,
        migrations: [
          BasicMigration(
            version: 1,
            onUp: (context) {
              context.execute('CREATE TABLE test1 (id INTEGER PRIMARY KEY)');
            },
          ),
          BasicMigration(
            version: 2,
            onUp: (context) {
              context.execute('Invalid SQL');
            },
          ),
        ],
      );

      expect(manager.runMigrations, throwsException);

      // Verify table was rolled back
      final tables = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='test1'",
      );
      expect(tables, isEmpty);

      // But history was preserved
      final history = manager.getMigrationHistory();
      expect(history, isNotEmpty);
    });

    test('includes timestamps in migration history', () {
      final now = DateTime.now().millisecondsSinceEpoch;

      final manager = DbMigrationManager.create(
        db: db,
        targetVersion: 1,
        migrations: [
          BasicMigration(
            version: 1,
            onUp: (context) {},
          ),
        ],
      )..runMigrations();

      final history = manager.getMigrationHistory();
      expect(history[0]['applied_at'], greaterThanOrEqualTo(now));
    });
  });

  group('history table recovery', () {
    late Database db;

    setUp(() {
      db = sqlite3.openInMemory();
    });

    tearDown(() {
      db.dispose();
    });

    test('recreates corrupted history table schema', () {
      // Create malformed history table
      db.execute('''
        CREATE TABLE ${DbMigrationManager.kMigrationHistoryTable} (
          version INTEGER PRIMARY KEY,
          applied_at INTEGER NOT NULL
          -- missing columns
        )
      ''');

      DbMigrationManager.create(
        db: db,
        targetVersion: 1,
        migrations: [
          BasicMigration(
            version: 1,
            onUp: (context) {},
          ),
        ],
      ).runMigrations();

      // Verify table was recreated with correct schema
      final columns = db
          .select(
            "PRAGMA table_info(${DbMigrationManager.kMigrationHistoryTable})",
          )
          .map((row) => row['name'] as String)
          .toSet();

      expect(
        columns,
        containsAll(['version', 'applied_at', 'success', 'error_message']),
      );
    });

    test('recovers from completely corrupted history table', () {
      // Create invalid table structure
      db.execute('''
        CREATE TABLE ${DbMigrationManager.kMigrationHistoryTable} (
          invalid_column TEXT
        )
      ''');

      final manager = DbMigrationManager.create(
        db: db,
        targetVersion: 1,
        migrations: [
          BasicMigration(
            version: 1,
            onUp: (context) {},
          ),
        ],
      )..runMigrations();

      // Verify table was recreated and migration succeeded
      final history = manager.getMigrationHistory();
      expect(history.length, equals(1));
      expect(history.first['version'], equals(1));
      expect(history.first['success'], equals(1));
    });
  });

  group('migration history gap', () {
    late Database db;

    setUp(() {
      db = sqlite3.openInMemory();
    });

    tearDown(() {
      db.dispose();
    });

    void setupDatabaseAtVersion2() {
      // Set DB version to 2 without migration history
      db.execute('PRAGMA user_version = 2');
    }

    List<Migration> createMigrations() {
      return [
        BasicMigration(
          version: 1,
          onUp: (context) {
            context.execute('CREATE TABLE v1 (id INTEGER PRIMARY KEY)');
          },
        ),
        BasicMigration(
          version: 2,
          onUp: (context) {
            context.execute('CREATE TABLE v2 (id INTEGER PRIMARY KEY)');
          },
        ),
        BasicMigration(
          version: 3,
          onUp: (context) {
            context.execute('CREATE TABLE v3 (id INTEGER PRIMARY KEY)');
          },
        ),
      ];
    }

    test('strict mode fails when history gap detected', () {
      setupDatabaseAtVersion2();

      final manager = DbMigrationManager.create(
        db: db,
        targetVersion: 3,
        migrations: createMigrations(),
        mode: MigrationMode.strict,
      );

      expect(
        manager.runMigrations,
        throwsA(isA<HistoryInconsistencyException>()),
      );
    });

    test('repair mode fills history gap and continues migration', () {
      setupDatabaseAtVersion2();

      final manager = DbMigrationManager.create(
        db: db,
        targetVersion: 3,
        migrations: createMigrations(),
        mode: MigrationMode.repair,
      )..runMigrations();

      // Verify final state
      final history = manager.getMigrationHistory();
      expect(history.length, equals(3));
      expect(
        history.map((h) => h['version']),
        containsAll([1, 2, 3]),
      );
      expect(
        history.every((h) => h['success'] == 1),
        isTrue,
      );

      // Verify user_version
      final version = db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(version, equals(3));
    });

    test('force mode ignores history and applies new migrations', () {
      setupDatabaseAtVersion2();

      final manager = DbMigrationManager.create(
        db: db,
        targetVersion: 3,
        migrations: createMigrations(),
        mode: MigrationMode.force,
      )..runMigrations();

      // Verify only new migration was logged
      final history = manager.getMigrationHistory();
      expect(history.length, equals(1));
      expect(history.first['version'], equals(3));
      expect(history.first['success'], equals(1));

      // Verify user_version
      final version = db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(version, equals(3));
    });

    test('validates migration state correctly', () {
      setupDatabaseAtVersion2();

      final manager = DbMigrationManager.create(
        db: db,
        targetVersion: 3,
        migrations: createMigrations(),
      );

      final state = manager.validateMigrationState(currentVersion: 2);

      expect(state.hasHistoryGap, isTrue);
      expect(state.hasVersionMismatch, isFalse);
      expect(state.missingVersions, unorderedEquals([1, 2]));
    });
  });
}
