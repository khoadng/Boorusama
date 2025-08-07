// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show join;
import 'package:shelf/shelf.dart' as shelf;
import 'package:version/version.dart';

// Project imports:
import '../../../foundation/clipboard.dart';
import '../preparation/preparation_pipeline.dart';
import '../preparation/version_checking.dart';
import '../types/backup_data_source.dart';
import '../types/types.dart';
import '../utils/backup_utils.dart';
import '../utils/data_converter.dart';
import '../utils/json_handler.dart';

abstract class JsonBackupSource<T> implements BackupDataSource {
  JsonBackupSource({
    required this.id,
    required this.priority,
    required this.version,
    required this.appVersion,
    required this.dataGetter,
    required this.executor,
    required this.handler,
    required this.ref,
    this.extraSteps = const [],
    this.validator,
  }) {
    converter = DataBackupConverter(
      version: version,
      exportVersion: appVersion,
    );
    importBuilder = ImportPreparationBuilder<T>(
      converter: converter,
      currentVersion: appVersion,
      extraSteps: extraSteps,
      validator: validator,
    );
  }

  @override
  final String id;

  @override
  final int priority;

  final int version;
  final Version? appVersion;
  final Future<T> Function() dataGetter;
  final Future<void> Function(T data, BuildContext? uiContext) executor;
  final JsonHandler<T> handler;
  final List<PreparationStep<T>> extraSteps;
  final bool Function(T data)? validator;
  final Ref ref;

  late final DataBackupConverter converter;
  late final ImportPreparationBuilder<T> importBuilder;

  @override
  BackupCapabilities get capabilities => BackupCapabilities(
    server: ServerCapability(
      export: _serveData,
      prepareImport: _prepareServerImport,
    ),
    file: FileCapability(
      export: _exportToFile,
      prepareImport: _prepareFileImport,
    ),
    clipboard: ClipboardCapability(
      export: _exportToClipboard,
      prepareImport: _prepareClipboardImport,
    ),
  );

  Future<shelf.Response> _serveData(shelf.Request request) async {
    final data = await dataGetter();
    final payload = handler.encode(data);
    final json = converter.encode(payload: payload);
    return shelf.Response.ok(
      json,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<ImportPreparation> _prepareServerImport(
    String serverUrl,
    BuildContext? uiContext,
  ) async {
    final dio = Dio(BaseOptions(baseUrl: serverUrl));
    final response = await dio.get(
      '/$id',
      options: Options(responseType: ResponseType.plain),
    );
    final data = response.data as String;

    if (uiContext == null || !uiContext.mounted) {
      return _noContextPrepare(data);
    }

    return _prepareImport(data, uiContext);
  }

  Future<ImportPreparation> _prepareImport(
    String data,
    BuildContext? uiContext,
  ) => _noContextPrepare(data);

  Future<void> _exportToFile(String directoryPath) async {
    await BackupUtils.ensureStoragePermissions(ref);

    final data = await dataGetter();
    final payload = handler.encode(data);
    final json = converter.encode(payload: payload);

    final timestamp = DateFormat('yyyy.MM.dd.HH.mm.ss').format(DateTime.now());
    final fileName = 'boorusama_${id}_$timestamp.json';

    await writeFileToDirectory(directoryPath, fileName, json);
  }

  Future<ImportPreparation> _prepareFileImport(
    String path,
    BuildContext? uiContext,
  ) async {
    final content = await readFile(path);

    if (uiContext == null || !uiContext.mounted) {
      return _noContextPrepare(content);
    }

    return importBuilder.prepare(
      content,
      handler.parse,
      executor,
      uiContext,
    );
  }

  Future<void> _exportToClipboard() async {
    final data = await dataGetter();
    final payload = handler.encode(data);
    final json = converter.encode(payload: payload);
    await AppClipboard.copy(json);
  }

  Future<ImportPreparation> _prepareClipboardImport(
    BuildContext? uiContext,
  ) async {
    final content = await AppClipboard.paste('text/plain');
    if (content == null || content.isEmpty) {
      throw const ImportErrorEmpty();
    }

    if (uiContext == null || !uiContext.mounted) {
      return _noContextPrepare(content);
    }

    return importBuilder.prepare(
      content,
      handler.parse,
      executor,
      uiContext,
    );
  }

  Future<ImportPreparation> _noContextPrepare(String data) =>
      importBuilder.prepare(
        data,
        handler.parse,
        executor,
        null,
      );

  Future<void> writeFileToDirectory(
    String directoryPath,
    String fileName,
    String content,
  ) async {
    try {
      final dir = Directory(directoryPath);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }

      final finalPath = join(directoryPath, fileName);
      final tempPath = '$finalPath.tmp';
      final tempFile = File(tempPath);

      try {
        await tempFile.writeAsString(content);
        await tempFile.rename(finalPath);
      } catch (e) {
        if (tempFile.existsSync()) {
          await tempFile.delete();
        }
        rethrow;
      }
    } catch (e, st) {
      if (e is PathAccessException) {
        throw DataExportNotPermitted(error: e, stackTrace: st);
      }
      throw DataExportError(error: e, stackTrace: st);
    }
  }

  Future<String> readFile(String path) async {
    try {
      final file = File(path);
      return await file.readAsString();
    } catch (e) {
      throw const ImportInvalidJson();
    }
  }
}
