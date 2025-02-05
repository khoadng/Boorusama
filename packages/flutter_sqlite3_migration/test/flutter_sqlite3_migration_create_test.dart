import 'package:flutter_sqlite3_migration/src/exceptions.dart';
import 'package:flutter_sqlite3_migration/src/migration.dart';
import 'package:flutter_sqlite3_migration/src/migration_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('create', () {
    late Database db;

    setUp(() {
      db = sqlite3.openInMemory();
    });

    tearDown(() {
      db.dispose();
    });

    test('throws on non-positive target version', () {
      expect(
        () => DbMigrationManager.create(
          db: db,
          targetVersion: -1,
          migrations: [
            BasicMigration(version: 1, onUp: (context) {}),
          ],
        ),
        throwsA(isA<NegativeTargetVersionException>()),
      );
    });

    test('throws on non-sequential migration versions', () {
      expect(
        () => DbMigrationManager.create(
          db: db,
          targetVersion: 3,
          migrations: [
            BasicMigration(version: 1, onUp: (context) {}),
            BasicMigration(version: 3, onUp: (context) {}),
          ],
        ),
        throwsA(
          isA<NonSequentialMigrationException>().having(
            (e) => e.message,
            'message',
            'Non-sequential migration versions between 1 and 3',
          ),
        ),
      );
    });

    test('throws when duplicate version exists', () {
      expect(
        () => DbMigrationManager.create(
          db: db,
          targetVersion: 2,
          migrations: [
            BasicMigration(version: 1, onUp: (context) {}),
            BasicMigration(version: 1, onUp: (context) {}), // Duplicate
          ],
        ),
        throwsA(isA<DuplicateMigrationVersionException>()),
      );
    });

    test('throws when DB version is higher than defined migrations', () {
      // Set the in-memory DB user_version to 100, which is above our defined migrations.
      db.execute('PRAGMA user_version = 100');

      // Define two migrations with versions less than 100.
      final migrations = [
        BasicMigration(version: 1, onUp: (context) {}),
        BasicMigration(version: 2, onUp: (context) {}),
      ];

      expect(
        () => DbMigrationManager.create(
          db: db,
          targetVersion: 2,
          migrations: migrations,
        ),
        throwsA(isA<FutureMigrationVersionException>()),
      );
    });

    test('throws when target version is within range but missing', () {
      expect(
        () => DbMigrationManager.create(
          db: db,
          targetVersion: 2,
          migrations: [
            BasicMigration(version: 1, onUp: (context) {}),
            BasicMigration(version: 3, onUp: (context) {}),
          ],
        ),
        throwsA(isA<MissingRangeMigrationException>()),
      );
    });
  });
}
