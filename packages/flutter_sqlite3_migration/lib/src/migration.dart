import 'package:sqlite3/sqlite3.dart';

typedef MigrationCallback = void Function(Database db);

class MigrationException implements Exception {
  MigrationException(this.message);
  final String message;

  @override
  String toString() => 'MigrationException: $message';
}

/// Controls how the migration manager handles inconsistencies
enum MigrationMode {
  /// Throws exceptions when encountering any history inconsistency
  strict,

  /// Attempts to repair history inconsistencies automatically
  repair,

  /// Ignores history validation and runs migrations anyway
  force
}

class MigrationState {
  const MigrationState({
    required this.hasHistoryGap,
    required this.hasVersionMismatch,
    required this.missingVersions,
  });

  final bool hasHistoryGap;
  final bool hasVersionMismatch;
  final List<int> missingVersions;
}

/// Context object passed to migration operations providing database access
///
/// Wraps common database operations in a convenient interface
class MigrationContext {
  MigrationContext(this.db);

  /// The underlying database connection
  final Database db;

  /// Executes a SQL statement
  void execute(String sql) => db.execute(sql);

  /// Executes a SQL query and returns results as a list of maps
  List<Map<String, dynamic>> select(String sql) => db.select(sql);
}

/// Base class for database migrations
///
/// Abstract class that defines the interface for up/down migrations
///
/// Example:
/// ```dart
/// class CreateUsersTable extends Migration {
///   CreateUsersTable() : super(version: 1, description: 'Create users table');
///
///   @override
///   void up(MigrationContext ctx) {
///     ctx.execute('''
///       CREATE TABLE users (
///         id INTEGER PRIMARY KEY,
///         name TEXT NOT NULL
///       )
///     ''');
///   }
///
///   @override
///   void down(MigrationContext ctx) {
///     ctx.execute('DROP TABLE users');
///   }
/// }
/// ```
abstract class Migration {
  Migration({
    required this.version,
    required this.description,
  });

  /// Sequential version number for this migration
  final int version;

  /// Human readable description of what this migration does
  final String description;

  /// Applies the migration moving forward
  void up(MigrationContext context);

  /// Reverts the migration moving backward
  void down(MigrationContext context);
}

/// Concrete implementation of Migration using function callbacks
///
/// Allows creating migrations without subclassing
///
/// Example:
/// ```dart
/// final migration = BasicMigration(
///   version: 1,
///   description: 'Create users table',
///   onUp: (ctx) => ctx.execute('CREATE TABLE users ...'),
///   onDown: (ctx) => ctx.execute('DROP TABLE users')
/// );
/// ```
class BasicMigration extends Migration {
  BasicMigration({
    required super.version,
    required this.onUp,
    this.onDown,
    String? description,
  }) : super(description: description ?? '');

  final void Function(MigrationContext) onUp;
  final void Function(MigrationContext)? onDown;

  @override
  void up(MigrationContext context) => onUp(context);

  @override
  void down(MigrationContext context) {
    if (onDown != null) {
      onDown!(context);
    }
  }
}
