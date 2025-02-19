import 'package:flutter_sqlite3_migration/src/migration.dart';
import 'package:flutter_sqlite3_migration/src/migration_manager.dart';
import 'package:flutter_sqlite3_migration/src/migration_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('progress tracking', () {
    late Database db;
    late List<MigrationEvent> events;

    setUp(() {
      db = sqlite3.openInMemory();
      events = [];
    });

    tearDown(() {
      db.dispose();
    });

    test('tracks migration progress events correctly', () {
      final migrations = [
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
      ];

      DbMigrationManager.create(
        db: db,
        targetVersion: 2,
        migrations: migrations,
      )
        ..addProgressListener(
          MigrationProgressListener(onEvent: events.add),
        )
        ..runMigrations();

      expect(events.length, equals(4)); // Start + 2 steps + Complete

      // Verify start event
      final startEvent = events[0] as MigrationStartedEvent;
      expect(startEvent.fromVersion, equals(0));
      expect(startEvent.targetVersion, equals(2));
      expect(startEvent.totalSteps, equals(2));

      // Verify step events
      final step1Event = events[1] as MigrationStepEvent;
      expect(step1Event.version, equals(1));
      expect(step1Event.currentStep, equals(1));
      expect(step1Event.totalSteps, equals(2));

      final step2Event = events[2] as MigrationStepEvent;
      expect(step2Event.version, equals(2));
      expect(step2Event.currentStep, equals(2));
      expect(step2Event.totalSteps, equals(2));

      // Verify completion event
      final completeEvent = events[3] as MigrationCompletedEvent;
      expect(completeEvent.finalVersion, equals(2));
      expect(completeEvent.duration, isNotNull);
    });

    test('tracks failed migration events', () {
      final migrations = [
        BasicMigration(
          version: 1,
          onUp: (context) {
            context.execute('INVALID SQL');
          },
        ),
      ];

      final manager = DbMigrationManager.create(
        db: db,
        targetVersion: 1,
        migrations: migrations,
      )..addProgressListener(
          MigrationProgressListener(onEvent: events.add),
        );

      expect(manager.runMigrations, throwsException);

      expect(events.length, equals(3)); // Start + Step + Failed

      // Verify start event
      final startEvent = events[0] as MigrationStartedEvent;
      expect(startEvent.fromVersion, equals(0));
      expect(startEvent.targetVersion, equals(1));
      expect(startEvent.totalSteps, equals(1));

      // Verify step event
      final stepEvent = events[1] as MigrationStepEvent;
      expect(stepEvent.version, equals(1));
      expect(stepEvent.currentStep, equals(1));
      expect(stepEvent.totalSteps, equals(1));

      // Verify failure event
      final failEvent = events[2] as MigrationFailedEvent;
      expect(failEvent.version, equals(0));
      expect(failEvent.error, isNotEmpty);
    });

    test('supports multiple progress listeners', () {
      final events2 = <MigrationEvent>[];

      final migrations = [
        BasicMigration(
          version: 1,
          onUp: (context) {
            context.execute('CREATE TABLE test (id INTEGER PRIMARY KEY)');
          },
        ),
      ];

      DbMigrationManager.create(
        db: db,
        targetVersion: 1,
        migrations: migrations,
      )
        ..addProgressListener(
          MigrationProgressListener(onEvent: events.add),
        )
        ..addProgressListener(
          MigrationProgressListener(onEvent: events2.add),
        )
        ..runMigrations();

      expect(events.length, equals(3)); // Start + Step + Complete
      expect(events2.length, equals(3));
      expect(
        events2.map((e) => e.runtimeType),
        equals(events.map((e) => e.runtimeType)),
      );
    });

    test('timestamps are monotonically increasing', () {
      final migrations = [
        BasicMigration(
          version: 1,
          onUp: (context) {
            context.execute('CREATE TABLE test (id INTEGER PRIMARY KEY)');
          },
        ),
      ];

      DbMigrationManager.create(
        db: db,
        targetVersion: 1,
        migrations: migrations,
      )
        ..addProgressListener(
          MigrationProgressListener(onEvent: events.add),
        )
        ..runMigrations();

      for (var i = 0; i < events.length - 1; i++) {
        expect(
          events[i].timestamp.isBefore(events[i + 1].timestamp) ||
              events[i].timestamp.isAtSameMomentAs(events[i + 1].timestamp),
          isTrue,
        );
      }
    });

    test('no events emitted for up-to-date database', () {
      // Set current version equal to target version
      db.execute('PRAGMA user_version = 1');

      final migrations = [
        BasicMigration(
          version: 1,
          onUp: (context) {
            context.execute('CREATE TABLE test (id INTEGER PRIMARY KEY)');
          },
        ),
      ];

      DbMigrationManager.create(
        db: db,
        targetVersion: 1,
        migrations: migrations,
        mode: MigrationMode.repair,
      )
        ..addProgressListener(
          MigrationProgressListener(onEvent: events.add),
        )
        ..runMigrations();

      expect(events, isEmpty);
    });
  });

  group('events', () {
    test('events creation and equality', () {
      final timestamp = DateTime.now();

      final event1 = MigrationStartedEvent(
        fromVersion: 1,
        targetVersion: 2,
        totalSteps: 3,
        timestamp: timestamp,
      );
      final event2 = MigrationStartedEvent(
        fromVersion: 1,
        targetVersion: 2,
        totalSteps: 3,
        timestamp: timestamp,
      );

      expect(event1, equals(event2));
    });

    test('step events tracks progress correctly', () {
      final step1 = MigrationStepEvent(
        version: 1,
        currentStep: 1,
        totalSteps: 3,
      );
      final step2 = MigrationStepEvent(
        version: 1,
        currentStep: 2,
        totalSteps: 3,
      );

      expect(step1 != step2, isTrue);
    });

    test('completed event tracks duration', () {
      final completed = MigrationCompletedEvent(
        finalVersion: 2,
        duration: const Duration(seconds: 1),
      );

      expect(completed.duration, equals(const Duration(seconds: 1)));
    });

    test('listener receives events', () {
      final events = <MigrationEvent>[];
      final listener = MigrationProgressListener(
        onEvent: events.add,
      );

      final startEvent = MigrationStartedEvent(
        fromVersion: 1,
        targetVersion: 2,
        totalSteps: 1,
      );
      listener.onEvent(startEvent);

      expect(events, contains(startEvent));
      expect(events.length, equals(1));
    });

    test('failed event contains error info', () {
      final failed = MigrationFailedEvent(
        version: 1,
        error: 'Test error',
      );

      expect(failed.version, equals(1));
      expect(failed.error, equals('Test error'));
    });
  });
}
