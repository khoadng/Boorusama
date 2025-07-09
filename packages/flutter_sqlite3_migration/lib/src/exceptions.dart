class MigrationException implements Exception {
  const MigrationException(this.message);
  final String message;

  @override
  String toString() => 'MigrationException: $message';
}

class NegativeTargetVersionException extends MigrationException {
  NegativeTargetVersionException(int version)
    : super('Target version must be equal or greater than 0, got: $version');
}

class NonSequentialMigrationException extends MigrationException {
  NonSequentialMigrationException(int version1, int version2)
    : super(
        'Non-sequential migration versions between $version1 and $version2',
      );
}

class MissingMigrationException extends MigrationException {
  MissingMigrationException(int version)
    : super('Missing migration step for version $version');
}

class HistoryInconsistencyException extends MigrationException {
  HistoryInconsistencyException(List<int> versions)
    : super(
        'Migration history inconsistent: Migration version $versions exists in migration map but was never applied. '
        'This could indicate a database schema mismatch.',
      );
}

class InvalidCurrentVersionException extends MigrationException {
  InvalidCurrentVersionException(int version)
    : super('Invalid current version: $version');
}

class RepairFailedException extends MigrationException {
  RepairFailedException(Object error)
    : super('Failed to repair migration history: $error');
}

class MissingRangeMigrationException extends MigrationException {
  MissingRangeMigrationException(int version)
    : super(
        'Target version $version is within migration range but has no corresponding migration',
      );
}

class DuplicateMigrationVersionException implements Exception {
  DuplicateMigrationVersionException(this.version);

  final int version;

  @override
  String toString() => 'Duplicate migration found for version $version';
}

class FutureMigrationVersionException implements Exception {
  FutureMigrationVersionException(
    this.currentVersion,
    this.maxDefinedVersion,
  );

  final int currentVersion;
  final int maxDefinedVersion;

  @override
  String toString() =>
      "Database version $currentVersion exceeds the maximum defined migration version $maxDefinedVersion.";
}
