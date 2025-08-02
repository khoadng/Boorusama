// Package imports:
import 'package:dio/dio.dart' hide Response;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shelf/shelf.dart';

// Project imports:
import '../../../../../foundation/clipboard.dart';
import '../../../foundation/info/package_info.dart';
import '../../settings/providers.dart';
import '../../settings/settings.dart';
import '../data_converter2.dart';
import '../registry/backup_data_source.dart';
import '../registry/backup_utils.dart';
import '../types.dart';

const kSettingsBackupVersion = 1;

class SettingsBackupSource implements BackupDataSource {
  SettingsBackupSource(this.ref);

  final Ref ref;

  @override
  Future<ExportDataPayload> parseImportData(String data) async {
    return BackupUtils.decodeWithVersion(converter, data);
  }

  @override
  String get id => 'settings';

  @override
  String get displayName => 'Settings';

  @override
  int get priority => 0;

  @override
  int get version => kSettingsBackupVersion;

  @override
  DataBackupConverter2 get converter => DataBackupConverter2(
    version: version,
    exportVersion: ref.read(appVersionProvider),
  );

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
  Future<Response> serveData(Request request) async {
    return BackupUtils.versionedJsonResponse(
      converter,
      [_currentSettings.toJson()],
    );
  }

  @override
  Future<void> consumeData(String serverUrl) async {
    try {
      final dio = Dio(BaseOptions(baseUrl: serverUrl));
      final response = await dio.get('/settings');

      final exportData = BackupUtils.decodeWithVersion(
        converter,
        response.data,
      );

      final settings = Settings.fromJson(exportData.data.first);
      await _updateSettings(settings);
    } catch (e) {
      throw const ImportInvalidJson();
    }
  }

  @override
  Future<void> exportToDirectory(String directoryPath) async {
    final json = BackupUtils.encodeWithVersion(
      converter,
      [_currentSettings.toJson()],
    );

    await BackupUtils.writeFileToDirectory(
      directoryPath,
      _generateFileName(),
      json,
    );
  }

  @override
  Future<void> exportToFile(String filePath) async {
    final json = BackupUtils.encodeWithVersion(
      converter,
      [_currentSettings.toJson()],
    );

    await BackupUtils.writeFile(filePath, json);
  }

  @override
  Future<void> importFromFile(String path) async {
    try {
      final content = await BackupUtils.readFile(path);
      final exportData = BackupUtils.decodeWithVersion(converter, content);
      final settings = Settings.fromJson(exportData.data.first);
      await _updateSettings(settings);
    } catch (e) {
      if (e is ImportError) rethrow;
      throw const ImportInvalidJsonField();
    }
  }

  @override
  Future<void> exportToClipboard() async {
    try {
      final json = BackupUtils.encodeWithVersion(
        converter,
        [_currentSettings.toJson()],
      );

      await AppClipboard.copy(json);
    } catch (e, st) {
      throw DataExportError(error: e, stackTrace: st);
    }
  }

  @override
  Future<void> importFromClipboard() async {
    try {
      final jsonString = await AppClipboard.paste('text/plain');

      if (jsonString == null || jsonString.isEmpty) {
        throw const ImportErrorEmpty();
      }

      final exportData = BackupUtils.decodeWithVersion(converter, jsonString);
      final settings = Settings.fromJson(exportData.data.first);
      await _updateSettings(settings);
    } catch (e) {
      if (e is ImportError) rethrow;
      throw const ImportInvalidJsonField();
    }
  }
}
