import 'package:flutter_sqlite3_migration/src/migration.dart';
import 'package:flutter_sqlite3_migration/src/migration_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('migrate', () {
    late Database db;

    setUp(() {
      db = sqlite3.openInMemory();
    });

    tearDown(() {
      db.dispose();
    });

    test('runs migrations and sets user_version', () {
      // Verify initial version is 0.
      final initialVersion =
          db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(initialVersion, equals(0));

      // Define two migrations:
      // - Migration for version 2 creates a test table.
      // - Migration for version 3 alters the test table.
      final migrations = [
        BasicMigration(
          version: 1,
          onUp: (context) {
            context.execute(
              'CREATE TABLE test_table (id INTEGER PRIMARY KEY, name TEXT);',
            );
          },
        ),
        BasicMigration(
          version: 2,
          onUp: (context) {
            context.execute('ALTER TABLE test_table ADD COLUMN age INTEGER;');
          },
        ),
      ];

      const targetVersion = 2;
      DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      ).runMigrations();

      // Check that PRAGMA user_version is updated.
      final updatedVersion =
          db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(updatedVersion, equals(targetVersion));

      // Verify table structure.
      final tableInfo = db.select("PRAGMA table_info('test_table')");
      // Expect three columns: id, name, and age.
      final columnNames = tableInfo.map((row) => row['name']).toList();
      expect(columnNames, containsAll(['id', 'name', 'age']));
    });

    test(
        'upgrades from old version to new version with multiple sequential migrations',
        () {
      // Start with a legacy database at version 1.
      db.execute('PRAGMA user_version = 1');

      // Migration for version 2: create a new table.
      // Migration for version 3: alter the table by adding a new column.
      final migrations = [
        BasicMigration(
          version: 2,
          onUp: (context) {
            context.execute(
              'CREATE TABLE multi_step (id INTEGER PRIMARY KEY, value TEXT)',
            );
          },
        ),
        BasicMigration(
          version: 3,
          onUp: (context) {
            context.execute(
              'ALTER TABLE multi_step ADD COLUMN extra TEXT DEFAULT "default"',
            );
          },
        ),
      ];

      const targetVersion = 3;
      DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      ).runMigrations();

      // Verify that user_version is updated.
      final updatedVersion =
          db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(updatedVersion, equals(targetVersion));

      // Verify that the table was created and then altered.
      final tableInfo = db.select("PRAGMA table_info('multi_step')");
      final columns = tableInfo.map((row) => row['name']).toList();
      expect(columns, containsAll(['id', 'value', 'extra']));

      // Optionally, verify that the default value is in effect by inserting and selecting a row.
      db.execute("INSERT INTO multi_step (id, value) VALUES (1, 'test')");
      final row = db.select("SELECT extra FROM multi_step WHERE id = 1").first;
      expect(row['extra'], equals('default'));
    });

    test('does nothing if no migrations are provided', () {
      const targetVersion = 1;
      DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: [],
      ).runMigrations();

      // Verify that user_version remains unchanged.
      final updatedVersion =
          db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(updatedVersion, equals(0));
    });

    test('handles no migrations and target version 0 on fresh database', () {
      // Fresh db starts at version 0
      final initialVersion =
          db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(initialVersion, equals(0));

      // Run with no migrations and target 0
      DbMigrationManager.create(
        db: db,
        targetVersion: 0,
        migrations: [],
      ).runMigrations();

      // Version should remain 0
      final finalVersion =
          db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(finalVersion, equals(0));
    });

    test('does nothing if already up-to-date', () {
      // Manually set the user_version to the target.
      db.execute('PRAGMA user_version = 3');

      final migrations = [
        BasicMigration(
          version: 2,
          onUp: (context) {
            context.execute(
              'CREATE TABLE test_table (id INTEGER PRIMARY KEY, name TEXT);',
            );
          },
        ),
        BasicMigration(
          version: 3,
          onUp: (context) {
            context.execute('ALTER TABLE test_table ADD COLUMN age INTEGER;');
          },
        ),
      ];

      const targetVersion = 3;
      DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
        mode: MigrationMode.repair,
      ).runMigrations();

      // Confirm user_version remains unchanged.
      final updatedVersion =
          db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(updatedVersion, equals(3));

      // Since no migrations ran, test_table should not exist.
      final result = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='test_table'",
      );
      expect(result, isEmpty);
    });

    test('rolls back on migration failure', () {
      final migrations = [
        BasicMigration(
          version: 2,
          onUp: (context) {
            context.execute(
              'CREATE TABLE test_table (id INTEGER PRIMARY KEY, name TEXT);',
            );
          },
        ),
        BasicMigration(
          version: 3,
          onUp: (context) {
            // This migration will fail by referencing a non-existent table.
            context.execute(
              'ALTER TABLE non_existent_table ADD COLUMN age INTEGER;',
            );
          },
        ),
      ];

      const targetVersion = 3;
      final migrationManager = DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      );

      // Expect the migration run to throw an exception.
      expect(migrationManager.runMigrations, throwsException);

      // Verify that all changes have been rolled back.
      final tables = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='test_table'",
      );
      expect(tables, isEmpty);

      // user_version should remain less than targetVersion.
      final updatedVersion =
          db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(updatedVersion, lessThan(targetVersion));
    });

    test('executes each migration callback exactly once', () {
      var migration2Counter = 0;
      var migration3Counter = 0;

      final migrations = [
        BasicMigration(
          version: 1,
          onUp: (context) {
            migration2Counter++;
            context
                .execute('CREATE TABLE test_table2 (id INTEGER PRIMARY KEY)');
          },
        ),
        BasicMigration(
          version: 2,
          onUp: (context) {
            migration3Counter++;
            context.execute('ALTER TABLE test_table2 ADD COLUMN name TEXT');
          },
        ),
      ];

      const targetVersion = 2;
      DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      ).runMigrations();

      expect(migration2Counter, equals(1));
      expect(migration3Counter, equals(1));
    });

    test('rolls back all changes if one migration fails mid-sequence', () {
      // First migration succeeds, second fails.
      final migrations = [
        BasicMigration(
          version: 2,
          onUp: (context) {
            context
                .execute('CREATE TABLE test_table3 (id INTEGER PRIMARY KEY)');
          },
        ),
        BasicMigration(
          version: 3,
          onUp: (context) {
            // Intentional failure
            context
                .execute('ALTER TABLE non_existent_table ADD COLUMN name TEXT');
          },
        ),
      ];

      const targetVersion = 3;
      final migrationManager = DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      );

      expect(migrationManager.runMigrations, throwsException);

      // Verify that even the successful migration did not persist.
      final tableExists = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='test_table3'",
      );
      expect(tableExists, isEmpty);

      final updatedVersion =
          db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(updatedVersion, lessThan(targetVersion));
    });

    test('handles a migration callback that does nothing', () {
      final migrations = [
        BasicMigration(
          version: 1,
          onUp: (context) {
            // Do nothing
          },
        ),
      ];

      const targetVersion = 1;
      DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      ).runMigrations();

      // Even though no schema change occurred, version must update.
      final updatedVersion =
          db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(updatedVersion, equals(targetVersion));
    });

    test('applies sequential dependent migrations', () {
      // Migration 1 creates a table; migration 2 inserts a row relying on that table.
      final migrations = [
        BasicMigration(
          version: 1,
          onUp: (context) {
            context.execute(
              'CREATE TABLE test_table_dep (id INTEGER PRIMARY KEY, value TEXT);',
            );
          },
        ),
        BasicMigration(
          version: 2,
          onUp: (context) {
            context.execute(
              "INSERT INTO test_table_dep (value) VALUES ('migrated');",
            );
          },
        ),
      ];

      const targetVersion = 2;
      DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      ).runMigrations();

      // Verify table creation and row insertion.
      final rows = db.select("SELECT value FROM test_table_dep");
      expect(rows, isNotEmpty);
      expect(rows.first['value'], equals('migrated'));
    });

    test('migration is idempotent when run twice', () {
      final migrations = [
        BasicMigration(
          version: 1,
          onUp: (context) {
            context.execute(
              'CREATE TABLE test_table_idem (id INTEGER PRIMARY KEY)',
            );
          },
        ),
      ];

      const targetVersion = 1;
      final migrationManager = DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      )
        // Run the migration once.
        ..runMigrations();
      // Capture version after first run.
      final versionAfterFirst =
          db.select('PRAGMA user_version').first.columnAt(0) as int;

      // Run migration a second time.
      migrationManager.runMigrations();
      final versionAfterSecond =
          db.select('PRAGMA user_version').first.columnAt(0) as int;

      expect(versionAfterFirst, equals(targetVersion));
      expect(versionAfterSecond, equals(targetVersion));
    });

    test('handles synchronous error in migration callback', () {
      final migrations = [
        BasicMigration(
          version: 2,
          onUp: (context) {
            throw Exception('Synchronous error in migration 2');
          },
        ),
      ];

      const targetVersion = 2;
      final migrationManager = DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      );
      expect(migrationManager.runMigrations, throwsException);

      // Verify user_version remains unchanged.
      final updatedVersion =
          db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(updatedVersion, lessThan(targetVersion));
    });

    test('applies migration that modifies multiple database objects', () {
      final migrations = [
        BasicMigration(
          version: 1,
          onUp: (context) {
            context
              ..execute(
                'CREATE TABLE multi_obj (id INTEGER PRIMARY KEY, value TEXT)',
              )
              ..execute(
                "CREATE INDEX idx_multi_obj_value ON multi_obj(value)",
              );
          },
        ),
      ];

      const targetVersion = 1;
      DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      ).runMigrations();

      // Verify table exists.
      final tableInfo = db.select("PRAGMA table_info('multi_obj')");
      expect(tableInfo, isNotEmpty);

      // Verify index is created.
      final indexes = db.select("PRAGMA index_list('multi_obj')");
      expect(indexes, isNotEmpty);
    });

    test('upgrades existing database preserving legacy table data', () {
      // Simulate an existing database at legacy version.
      db
        ..execute('PRAGMA user_version = 1')
        // Legacy table without the "email" column.
        ..execute('CREATE TABLE user_table (id INTEGER PRIMARY KEY, name TEXT)')
        ..execute("INSERT INTO user_table (name) VALUES ('Alice')");

      // Migration for version 2: alter table to add "email" with a default.
      final migrations = [
        BasicMigration(
          version: 2,
          onUp: (context) {
            context.execute(
              "ALTER TABLE user_table ADD COLUMN email TEXT DEFAULT 'unknown'",
            );
          },
        ),
      ];

      const targetVersion = 2;
      DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      ).runMigrations();

      // Verify that the table now has the new column.
      final tableInfo = db.select("PRAGMA table_info('user_table')");
      final columnNames = tableInfo.map((row) => row['name']).toList();
      expect(columnNames, containsAll(['id', 'name', 'email']));

      // Pre-existing data should remain intact with the default value.
      final row =
          db.select("SELECT * FROM user_table WHERE name = 'Alice'").first;
      expect(row['name'], equals('Alice'));
      expect(row['email'], equals('unknown'));

      // Verify that user_version was updated.
      final updatedVersion =
          db.select('PRAGMA user_version').first.columnAt(0) as int;
      expect(updatedVersion, equals(targetVersion));
    });

    test('upgrades legacy database with data transformation migration', () {
      // Simulate an existing legacy database.
      db
        ..execute('PRAGMA user_version = 1')
        // Legacy table "product" with a "price" column.
        ..execute(
          'CREATE TABLE product (id INTEGER PRIMARY KEY, price INTEGER)',
        )
        ..execute("INSERT INTO product (price) VALUES (100)");

      // Migration for version 2: add a new column and update it from the existing data.
      final migrations = [
        BasicMigration(
          version: 2,
          onUp: (context) {
            // Add new column "price_in_usd".
            context
              ..execute("ALTER TABLE product ADD COLUMN price_in_usd REAL")
              // Transform data: assume conversion factor is price / 100.0.
              ..execute("UPDATE product SET price_in_usd = price / 100.0");
          },
        ),
      ];

      const targetVersion = 2;
      DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      ).runMigrations();

      // Verify that "product" table now contains the new column.
      final tableInfo = db.select("PRAGMA table_info('product')");
      final columnNames = tableInfo.map((row) => row['name']).toList();
      expect(columnNames, containsAll(['id', 'price', 'price_in_usd']));

      // Verify that the pre-existing row was transformed correctly.
      final row = db.select("SELECT * FROM product WHERE id = 1").first;
      expect(row['price'], equals(100));
      expect(row['price_in_usd'], closeTo(1.0, 0.001));
    });
  });

  group('out-of-order migrations setup', () {
    late Database db;

    setUp(() {
      db = sqlite3.openInMemory();
    });

    tearDown(() {
      db.dispose();
    });

    test('executes out-of-order migrations in correct version sequence', () {
      // Define migrations in random order
      final migrations = [
        BasicMigration(
          version: 3,
          onUp: (context) {
            context.execute('CREATE TABLE v3 (id INTEGER PRIMARY KEY)');
          },
        ),
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
      ];

      const targetVersion = 3;
      final manager = DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      )..runMigrations();

      // Verify migrations executed in correct order via history
      final history = manager.getMigrationHistory();
      expect(history.length, equals(3));

      // Most recent first in history
      expect(history[0]['version'], equals(3));
      expect(history[1]['version'], equals(2));
      expect(history[2]['version'], equals(1));

      // Verify all tables were created
      final tables = db
          .select(
            "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('v1','v2','v3')",
          )
          .map((row) => row['name'] as String)
          .toList();

      expect(tables, containsAll(['v1', 'v2', 'v3']));
    });

    test('handles out-of-order dependent migrations correctly', () {
      // Define dependent migrations in reverse order
      final migrations = [
        BasicMigration(
          version: 2,
          onUp: (context) {
            // This depends on v1 table existing
            context.execute('ALTER TABLE v1_table ADD COLUMN new_col TEXT');
          },
        ),
        BasicMigration(
          version: 1,
          onUp: (context) {
            context.execute('CREATE TABLE v1_table (id INTEGER PRIMARY KEY)');
          },
        ),
      ];

      const targetVersion = 2;
      DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      ).runMigrations();

      // Verify table structure includes both changes
      final tableInfo = db.select("PRAGMA table_info('v1_table')");
      final columns = tableInfo.map((row) => row['name'] as String).toList();
      expect(columns, containsAll(['id', 'new_col']));
    });

    test('maintains data consistency with out-of-order migrations', () {
      final migrations = [
        BasicMigration(
          version: 3,
          onUp: (context) {
            context.execute("INSERT INTO test_table (name) VALUES ('test3')");
          },
        ),
        BasicMigration(
          version: 1,
          onUp: (context) {
            context.execute(
              'CREATE TABLE test_table (id INTEGER PRIMARY KEY, name TEXT)',
            );
          },
        ),
        BasicMigration(
          version: 2,
          onUp: (context) {
            context.execute("INSERT INTO test_table (name) VALUES ('test2')");
          },
        ),
      ];

      const targetVersion = 3;
      DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      ).runMigrations();

      // Verify data was inserted in correct order
      final rows = db.select('SELECT name FROM test_table ORDER BY id');
      expect(rows.length, equals(2));
      expect(rows[0]['name'], equals('test2')); // Version 2 insert
      expect(rows[1]['name'], equals('test3')); // Version 3 insert
    });

    test(
        'fails appropriately with out-of-order migrations missing dependencies',
        () {
      final migrations = [
        BasicMigration(
          version: 2,
          onUp: (context) {
            // This will fail because v1 doesn't create the required table
            context.execute('ALTER TABLE missing_table ADD COLUMN test TEXT');
          },
        ),
        BasicMigration(
          version: 1,
          onUp: (context) {
            context.execute(
              'CREATE TABLE different_table (id INTEGER PRIMARY KEY)',
            );
          },
        ),
      ];

      const targetVersion = 2;
      final manager = DbMigrationManager.create(
        db: db,
        targetVersion: targetVersion,
        migrations: migrations,
      );

      expect(manager.runMigrations, throwsException);

      // Verify no tables were created (rollback worked)
      final tables = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('different_table', 'missing_table')",
      );
      expect(tables, isEmpty);
    });
  });
}
