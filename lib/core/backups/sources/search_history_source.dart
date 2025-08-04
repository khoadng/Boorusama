// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../search/histories/providers.dart';
import '../widgets/backup_restore_tile.dart';
import 'sqlite_source.dart';

class SearchHistoryBackupSource extends SqliteBackupSource {
  SearchHistoryBackupSource(Ref ref)
    : super(
        id: 'search_histories',
        priority: 3,
        ref: ref,
        dbPathGetter: getSearchHistoryDbPath,
        dbFileName: kSearchHistoryDbName,
        onImportComplete: () => ref.invalidate(searchHistoryRepoProvider),
      );

  @override
  String get displayName => 'Search histories';

  @override
  Widget buildTile(BuildContext context) {
    return DefaultBackupTile(
      source: this,
      title: 'Search histories',
      icon: Symbols.history,
      fileExtensions: const ['db'],
      forceAnyFileType: true,
    );
  }
}
