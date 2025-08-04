// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../bulk_downloads/providers.dart';
import '../widgets/backup_restore_tile.dart';
import 'sqlite_source.dart';

class DownloadsBackupSource extends SqliteBackupSource {
  DownloadsBackupSource(Ref ref)
    : super(
        id: 'downloads',
        priority: 4,
        ref: ref,
        dbPathGetter: getDownloadsDbPath,
        dbFileName: kDownloadDbName,
        onImportComplete: () =>
            ref.invalidate(internalDownloadRepositoryProvider),
      );

  @override
  String get displayName => 'Downloads';

  @override
  Widget buildTile(BuildContext context) {
    return DefaultBackupTile(
      source: this,
      title: 'Bulk downloads',
      icon: Symbols.folder_zip,
      fileExtensions: const ['db'],
      forceAnyFileType: true,
    );
  }
}
