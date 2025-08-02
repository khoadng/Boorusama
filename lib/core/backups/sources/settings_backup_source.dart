// Package imports:
import 'package:dio/dio.dart' hide Response;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shelf/shelf.dart';

// Project imports:
import '../../../../../foundation/clipboard.dart';
import '../registry/backup_data_source.dart';
import '../registry/backup_utils.dart';
import '../types.dart';
import '../../settings/providers.dart';
import '../../settings/settings.dart';

class SettingsBackupSource implements BackupDataSource {
  SettingsBackupSource(this.ref);

  final Ref ref;

  @override
  String get id => 'settings';

  @override
  String get displayName => 'Settings';

  @override
  int get priority => 0;

  @override
  BackupSourceConfig get uiConfig => const BackupSourceConfig(
    icon: Symbols.settings,
    actions: [
      BackupAction(type: BackupActionType.export, label: 'Export'),
      BackupAction(type: BackupActionType.import, label: 'Import'),
      BackupAction(
        type: BackupActionType.exportClipboard,
        label: 'Export to clipboard',
      ),
      BackupAction(
        type: BackupActionType.importClipboard,
        label: 'Import from clipboard',
      ),
    ],
  );

  String _generateFileName() {
    final timestamp = DateFormat('yyyy.MM.dd.HH.mm.ss').format(DateTime.now());
    return 'boorusama_settings_$timestamp.json';
  }

  Settings get _currentSettings => ref.read(settingsProvider);

  Future<void> _updateSettings(Settings settings) async {
    await ref.read(settingsNotifierProvider.notifier).updateSettings(settings);
  }

  @override
  Future<Either<ExportError, Response>> serveData(Request request) async {
    return BackupUtils.encodeJson(
      _currentSettings.toJson(),
    ).map(BackupUtils.jsonResponse).run();
  }

  @override
  Future<Either<ImportError, Unit>> consumeData(String serverUrl) async {
    return TaskEither.tryCatch(
      () async {
        final dio = Dio(BaseOptions(baseUrl: serverUrl));
        final response = await dio.get('/settings');
        final settings = Settings.fromJson(response.data);
        await _updateSettings(settings);
        return unit;
      },
      (e, st) => const ImportInvalidJson(),
    ).run();
  }

  @override
  Future<Either<ExportError, Unit>> exportToDirectory(
    String directoryPath,
  ) async {
    return BackupUtils.encodeJson(_currentSettings.toJson())
        .flatMap(
          (json) => BackupUtils.writeFileToDirectory(
            directoryPath,
            _generateFileName(),
            json,
          ),
        )
        .run();
  }

  @override
  Future<Either<ExportError, Unit>> exportToFile(String filePath) async {
    return BackupUtils.encodeJson(
      _currentSettings.toJson(),
    ).flatMap((json) => BackupUtils.writeFile(filePath, json)).run();
  }

  @override
  Future<Either<ImportError, Unit>> importFromFile(String path) async {
    return BackupUtils.readFile(path)
        .flatMap(
          (content) => BackupUtils.decodeJson(
            content,
            Settings.fromJson,
          ),
        )
        .flatMap(
          (settings) => TaskEither.tryCatch(
            () async {
              await _updateSettings(settings);
              return unit;
            },
            (e, st) => const ImportInvalidJsonField(),
          ),
        )
        .run();
  }

  @override
  Future<Either<ExportError, Unit>> exportToClipboard() async {
    return BackupUtils.encodeJson(_currentSettings.toJson())
        .flatMap(
          (json) => TaskEither.tryCatch(
            () async {
              await AppClipboard.copy(json);
              return unit;
            },
            (e, st) => DataExportError(error: e, stackTrace: st),
          ),
        )
        .run();
  }

  @override
  Future<Either<ImportError, Unit>> importFromClipboard() async {
    return TaskEither.tryCatch(
          () async {
            final jsonString = await AppClipboard.paste('text/plain');

            if (jsonString == null || jsonString.isEmpty) {
              throw Exception('Clipboard is empty');
            }

            return jsonString;
          },
          (e, st) => const ImportErrorEmpty() as ImportError,
        )
        .flatMap(
          (content) => BackupUtils.decodeJson(content, Settings.fromJson),
        )
        .flatMap(
          (settings) => TaskEither.tryCatch(
            () async {
              await _updateSettings(settings);
              return unit;
            },
            (e, st) => const ImportInvalidJsonField() as ImportError,
          ),
        )
        .run();
  }
}
