// Dart imports:
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import 'package:boorusama/core/app_scope.dart';
import 'package:boorusama/core/backups/preparation/version_checking.dart';
import 'package:boorusama/core/backups/types/backup_data_source.dart';
import 'package:boorusama/core/backups/widgets/backup_restore_tile.dart';
import 'package:boorusama/core/backups/widgets/data_transfer_card.dart';
import 'package:boorusama/core/backups/widgets/manual_backup_page.dart';
import 'package:boorusama/core/backups/zip/backup_notifier.dart';
import 'package:boorusama/core/search/selected_tags/types.dart';
import 'package:boorusama/core/settings/src/pages/backup_and_restore_page.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/core/tags/favorites/types.dart';
import 'package:boorusama/foundation/filesystem.dart';
import 'package:boorusama/foundation/platform.dart';

import '../support/boorusama_test_runtime.dart';
import 'support/fake_booru_backend.dart';
import 'support/fake_image_dio.dart';
import 'support/headless_app_harness.dart';

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

  testWidgets('reaches backup restore through the real settings flow', (
    tester,
  ) async {
    final backend = FakeBooruBackend();
    final picker = TestAppFilePicker(filePath: '/memory/settings.json');
    final fileSystem = MemoryAppFileSystem();
    await fileSystem.writeString(
      '/memory/settings.json',
      jsonEncode(
        Settings.defaultSettings
            .copyWith(currentBooruConfigId: backend.config.id)
            .toJson(),
      ),
    );

    final runtime = backend.createRuntime(
      appFilePicker: picker,
      fileSystem: fileSystem,
    );
    final harness = HeadlessAppHarness(
      booruBackend: backend,
      runtime: runtime,
    );
    addTearDown(() => harness.teardown(tester));

    await harness.pump(tester);
    await harness.settle(tester);

    await _openBackupAndRestore(tester, harness);

    final advancedBackup = find.textContaining('Advanced');
    await tester.ensureVisible(advancedBackup);
    await tester.tap(advancedBackup);
    await tester.pump();
    await harness.settle(tester);

    expect(find.byType(ManualBackupPage), findsOneWidget);
    final settingsTile = find.ancestor(
      of: find.text('Settings').last,
      matching: find.byType(DefaultBackupTile),
    );
    await tester.tap(
      find.descendant(
        of: settingsTile,
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pump();
    await harness.pumpUntilFound(tester, find.text('Import'));
    await tester.tap(find.text('Import').last);
    await harness.settle(tester);

    expect(picker.pickedFiles, ['/memory/settings.json']);
    expect(
      (runtime.dependencies.settingsRepository as MemorySettingsRepository)
          .savedSettings,
      isNotEmpty,
    );
  });

  testWidgets(
    'exports saved favorite tags in a full backup before opening favorites',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync(
        'boorusama_backup_flow_',
      );
      addTearDown(() => directory.deleteSync(recursive: true));
      final savedTags = [
        FavoriteTag(
          name: 'cityscape',
          createdAt: DateTime.utc(2020),
          updatedAt: null,
          labels: null,
        ),
        FavoriteTag(
          name: 'rating:safe score:>=20',
          createdAt: DateTime.utc(2021),
          updatedAt: DateTime.utc(2022),
          labels: const ['daily', 'reference'],
          queryType: QueryType.simple,
        ),
      ];
      final repository = MemoryFavoriteTagRepository();
      await repository.createFrom(savedTags);
      final picker = TestAppFilePicker(directoryPath: directory.path);

      const permissionChannel = MethodChannel(
        'flutter.baseflow.com/permissions/methods',
      );
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        permissionChannel,
        (call) async => call.method == 'checkPermissionStatus' ? 1 : null,
      );
      addTearDown(
        () => messenger.setMockMethodCallHandler(permissionChannel, null),
      );

      final backend = FakeBooruBackend();
      final harness = await HeadlessAppHarness.mount(
        tester,
        booruBackend: backend,
        additionalOverrides: [
          deterministicFaviconDioOverride(),
          deterministicImageDioOverride(),
        ],
        runtime: backend.createRuntime(
          platform: AppPlatform.android,
          favoriteTagRepository: repository,
          appFilePicker: picker,
          fileSystem: _BackupFlowFileSystem(directory.path),
        ),
      );
      await harness.settle(tester);
      await _openBackupAndRestore(tester, harness);

      final exportCard = find.ancestor(
        of: find.text('Export'),
        matching: find.byType(DataTransferCard),
      );
      expect(exportCard, findsOneWidget);
      await tester.ensureVisible(exportCard);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(BackupAndRestorePage)),
      );
      await tester.tap(exportCard);
      // Let disk I/O and the ZIP isolate progress between widget pumps.
      for (var i = 0; i < 200 && container.read(backupProvider).isActive; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      await harness.settle(tester);

      final state = container.read(backupProvider);
      expect(state.status, BackupStatus.completed, reason: state.error);
      expect(picker.pickedDirectories, [directory.path]);
      final archive = ZipDecoder().decodeBytes(
        File(state.exportResult!.filePath).readAsBytesSync(),
      );
      final manifest = jsonDecode(
        utf8.decode(archive.findFile('manifest.json')!.readBytes()!),
      ) as Map<String, dynamic>;
      final sourceFiles = manifest['sourceFiles'] as Map<String, dynamic>;
      expect(manifest['failed'], isEmpty);
      expect(
        [...sourceFiles.keys, ...manifest['skipped'] as List<dynamic>],
        unorderedEquals([
          'profiles',
          'settings',
          'favorite_tags',
          'blacklisted_tags',
          'bookmarks',
          'search_histories',
          'downloads',
        ]),
      );

      final tagsFile = archive.findFile(
        sourceFiles['favorite_tags'] as String,
      )!;
      final tagsPayload = jsonDecode(
        utf8.decode(tagsFile.readBytes()!),
      ) as Map<String, dynamic>;
      expect(
        tagsPayload['data'],
        savedTags.map((tag) => tag.toJson()).toList(),
      );
    },
  );
}

Future<void> _openBackupAndRestore(
  WidgetTester tester,
  HeadlessAppHarness harness,
) async {
  final settingsIcon = find.byIcon(Symbols.settings);
  if (settingsIcon.evaluate().isNotEmpty) {
    await tester.tap(settingsIcon.last);
  } else {
    await tester.tap(find.byIcon(Symbols.menu).first);
    await tester.pump();
    await harness.settle(tester);
    await tester.tap(find.text('Settings').last);
  }
  await tester.pump();
  await harness.settle(tester);

  final backupCategory = find.text('Backup and Restore');
  await tester.ensureVisible(backupCategory);
  await tester.tap(backupCategory);
  await tester.pump();
  await harness.settle(tester);
  expect(find.byType(BackupAndRestorePage), findsOneWidget);
}

final class _BackupFlowFileSystem extends IoFileSystem {
  const _BackupFlowFileSystem(this.storagePath);

  final String storagePath;

  @override
  Future<String> getAppStoragePath() async => storagePath;
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
