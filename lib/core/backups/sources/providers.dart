// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/backup_data_source.dart';
import '../types/backup_registry.dart';
import 'blacklisted_tags_source.dart';
import 'bookmarks_source.dart';
import 'booru_configs_source.dart';
import 'downloads_source.dart';
import 'favorite_tags_source.dart';
import 'search_history_source.dart';
import 'settings_source.dart';

final booruConfigsBackupSourceProvider = Provider<BackupDataSource>((ref) {
  return BooruConfigsBackupSource(ref);
});

final settingsBackupSourceProvider = Provider<BackupDataSource>((ref) {
  return SettingsBackupSource(ref);
});

final favoriteTagsBackupSourceProvider = Provider<BackupDataSource>((ref) {
  return FavoriteTagsBackupSource(ref);
});

final blacklistedTagsBackupSourceProvider = Provider<BackupDataSource>((ref) {
  return BlacklistedTagsBackupSource(ref);
});

final searchHistoryBackupSourceProvider = Provider<BackupDataSource>((ref) {
  return SearchHistoryBackupSource(ref);
});

final downloadsBackupSourceProvider = Provider<BackupDataSource>((ref) {
  return DownloadsBackupSource(ref);
});

final bookmarksBackupSourceProvider = Provider<BackupDataSource>((ref) {
  return BookmarksBackupSource(ref);
});

final backupRegistryProvider = Provider<BackupRegistry>((ref) {
  final registry = BackupRegistry()
    ..register(ref.read(booruConfigsBackupSourceProvider))
    ..register(ref.read(settingsBackupSourceProvider))
    ..register(ref.read(favoriteTagsBackupSourceProvider))
    ..register(ref.read(searchHistoryBackupSourceProvider))
    ..register(ref.read(downloadsBackupSourceProvider))
    ..register(ref.read(blacklistedTagsBackupSourceProvider))
    ..register(ref.read(bookmarksBackupSourceProvider));
  return registry;
});

final allBackupSourcesProvider = Provider<void>((ref) {
  ref
    ..watch(booruConfigsBackupSourceProvider)
    ..watch(settingsBackupSourceProvider)
    ..watch(favoriteTagsBackupSourceProvider)
    ..watch(searchHistoryBackupSourceProvider)
    ..watch(downloadsBackupSourceProvider)
    ..watch(blacklistedTagsBackupSourceProvider)
    ..watch(bookmarksBackupSourceProvider);
});
