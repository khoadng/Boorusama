# SQLite Migration Manager for Dart

A robust and flexible SQLite database migration manager for Dart applications. This package simplifies schema versioning, supports migration events, and offers multiple strategies for handling migration inconsistencies.

## Features

- **Versioned Migrations**: Manage database schema changes through incremental versioned migration scripts.
- **Migration History Tracking**: Automatically tracks applied migrations in a dedicated table.
- **Validation Modes**: Choose between strict, repair, or force modes to handle migration inconsistencies.
- **Event Listeners**: Monitor migration progress with start, step, completion, and failure events.
- **Rollback Support**: Define down migrations for potential manual rollbacks (manual execution required).
- **Baseline Versioning**: Initialize databases with existing schemas at specific versions.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_sqlite3_migration: ^0.0.1
```

## Usage

### 1. Define Migrations

Create migration classes by extending `Migration`:

```dart
class CreateUsersTable extends Migration {
  CreateUsersTable()
      : super(
          version: 1,
          description: 'Creates initial users table',
        );

  @override
  void up(MigrationContext context) {
    context.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE
      )
    ''');
  }

  @override
  void down(MigrationContext context) {
    context.execute('DROP TABLE users');
  }
}
```

Or use `BasicMigration` for quick setup:

```dart
final addAgeColumn = BasicMigration(
  version: 2,
  description: 'Adds age column to users table',
  onUp: (context) => context.execute('ALTER TABLE users ADD COLUMN age INTEGER'),
  onDown: (context) => context.execute('ALTER TABLE users DROP COLUMN age'),
);
```

### 2. Initialize Migration Manager

```dart
final db = sqlite3.open('app.db');

final manager = DbMigrationManager.create(
  db: db,
  targetVersion: 2,
  migrations: [CreateUsersTable(), addAgeColumn],
  mode: MigrationMode.strict,
);
```

### 3. Run Migrations

```dart
try {
  manager.runMigrations();
  print('Database migrated successfully!');
} on MigrationException catch (e) {
  print('Migration failed: ${e.message}');
}
```

### 4. Track Migration Events

```dart
manager.addProgressListener((event) {
  if (event is MigrationStartedEvent) {
    print('Migrating from ${event.fromVersion} to ${event.targetVersion}');
  } else if (event is MigrationStepEvent) {
    print('Applying version ${event.version} (${event.currentStep}/${event.totalSteps})');
  } else if (event is MigrationCompletedEvent) {
    print('Migration completed in ${event.duration}');
  } else if (event is MigrationFailedEvent) {
    print('Failed at version ${event.version}: ${event.error}');
  }
});
```

## Migration Modes

### Strict Mode (Default)
- Validates complete migration history
- Throws `HistoryInconsistencyException` if gaps or mismatches are found

### Repair Mode
- Attempts to fix missing version records
- Useful for recovering from partial migrations

### Force Mode
- Ignores migration history validation
- Applies all pending migrations regardless of state

## Validation & Error Handling

Check migration state before execution:

```dart
final state = manager.validateMigrationState(currentVersion: currentVersion);

if (state.hasHistoryGap) {
  print('Missing migrations: ${state.missingVersions}');
}
```

Common exceptions:
- `MissingMigrationException`: No migration found for target version
- `NonSequentialMigrationException`: Gaps in migration versions
- `RepairFailedException`: Automatic history repair failed

## Migration History Table

The package maintains a `migrations_history` table with this structure:

| Column        | Type    | Description                     |
|---------------|---------|---------------------------------|
| version       | INTEGER | Migration version number (PK)  |
| applied_at    | INTEGER | Timestamp of application (ms)  |
| success       | INTEGER | 1 for success, 0 for failure   |
| error_message | TEXT    | Failure details if unsuccessful |

Retrieve migration history:

```dart
final history = manager.getMigrationHistory();
```

## Limitations

Only support up migrations. Down migrations are currently ignored for now.

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with tests

## License

MIT License - See [LICENSE](LICENSE) for details.