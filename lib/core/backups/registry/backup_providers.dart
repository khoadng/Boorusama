// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../sources/settings_backup_source.dart';
import 'backup_data_source.dart';
import 'backup_registry.dart';

final settingsBackupSourceProvider = Provider<BackupDataSource>((ref) {
  return SettingsBackupSource(ref);
});

final backupRegistryProvider = Provider<BackupRegistry>((ref) {
  final registry = BackupRegistry()
    ..register(ref.read(settingsBackupSourceProvider));

  return registry;
});

// Helper provider to ensure all sources are registered
final allBackupSourcesProvider = Provider<void>((ref) {
  // Watch all backup source providers to trigger registration
  ref.watch(settingsBackupSourceProvider);
  // Add other sources here as they're implemented
});
