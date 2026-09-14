// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import 'package:boorusama/core/app_scope.dart';
import 'package:boorusama/core/backups/preparation/version_checking.dart';
import 'package:boorusama/core/backups/types/backup_data_source.dart';
import 'package:boorusama/core/backups/widgets/backup_restore_tile.dart';

import '../support/boorusama_test_runtime.dart';

void main() {
  testWidgets('restores a backup file through the picker boundary', (
    tester,
  ) async {
    final picker = TestAppFilePicker(filePath: '/memory/settings.json');
    final source = _RecordingBackupSource();

    await tester.pumpWidget(
      BoorusamaAppScope(
        runtime: createTestBoorusamaRuntime(appFilePicker: picker),
        child: OKToast(
          duration: Duration.zero,
          child: MaterialApp(
            home: Scaffold(
              body: DefaultBackupTile(
                source: source,
                title: 'Test backup',
                icon: Icons.settings,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    try {
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import'));
      await tester.pump();

      expect(source.importedPaths, ['/memory/settings.json']);
    } finally {
      dismissAllToast();
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
    }
  });
}

final class _RecordingBackupSource implements BackupDataSource {
  final importedPaths = <String>[];

  @override
  String get id => 'test';

  @override
  int get priority => 0;

  @override
  String get displayName => 'Test backup';

  @override
  BackupCapabilities get capabilities => BackupCapabilities(
    server: ServerCapability(
      export: (_) async => shelf.Response.ok(''),
      prepareImport: (_, _) async => _preparation,
    ),
    file: FileCapability(
      export: (_) async {},
      prepareImport: (path, _) async {
        importedPaths.add(path);
        return _preparation;
      },
    ),
  );

  @override
  Widget buildTile(BuildContext context) =>
      throw UnimplementedError('The test mounts DefaultBackupTile directly');

  static const _preparation = ImportPreparation(
    versionCheck: VersionCheckInfo(
      result: VersionCheckResult.compatible,
      currentVersion: null,
      importVersion: null,
    ),
    executeImport: _completeImport,
  );

  static Future<void> _completeImport() async {}
}
