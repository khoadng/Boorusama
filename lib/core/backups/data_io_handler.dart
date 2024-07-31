// Dart imports:
import 'dart:io';

// Package imports:
import 'package:version/version.dart';

// Project imports:
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/functional.dart';
import 'backups.dart';

class DataIOHandler {
  DataIOHandler({
    required this.permissionChecker,
    required this.permissionRequester,
    required this.exporter,
    required this.importer,
    required this.version,
    required this.exportVersion,
  });

  factory DataIOHandler.file({
    required DeviceInfo deviceInfo,
    required String prefixName,
    required int version,
    required Version? exportVersion,
  }) =>
      DataIOHandler(
        version: version,
        exportVersion: exportVersion,
        permissionChecker: () => checkMediaPermissions(deviceInfo),
        permissionRequester: () => requestMediaPermissions(deviceInfo),
        exporter: (path, data) async {
          final dir = Directory(path);
          final date = DateFormat('yyyy.MM.dd.mm.ss').format(DateTime.now());
          final file = File(join(dir.path, '${prefixName}_$date.json'));

          await file.writeAsString(data);
        },
        importer: (path) async {
          final file = File(path);
          final jsonString = await file.readAsString();

          return jsonString;
        },
      );

  final Future<PermissionStatus> Function() permissionChecker;
  final Future<PermissionStatus> Function() permissionRequester;
  final Future<void> Function(String path, String data) exporter;
  final Future<String> Function(String path) importer;
  final int version;
  final Version? exportVersion;

  TaskEither<ExportError, Unit> export({
    required List<dynamic> data,
    required String path,
  }) =>
      TaskEither.Do(
        ($) async {
          final status = await permissionChecker();

          if (status != PermissionStatus.granted) {
            final status = await permissionRequester();

            if (status != PermissionStatus.granted) {
              return $(TaskEither.left(const StoragePermissionDenied()));
            }
          }

          final jsonString = await $(tryEncodeData(
            version: version,
            exportDate: DateTime.now(),
            exportVersion: exportVersion,
            payload: data,
          ).toTaskEither());

          return await $(TaskEither.tryCatch(
            () async {
              await exporter(path, jsonString);

              return unit;
            },
            (e, st) {
              if (e is PathAccessException) {
                return DataExportNotPermitted(
                  error: e,
                  stackTrace: st,
                );
              } else {
                return DataExportError(
                  error: e,
                  stackTrace: st,
                );
              }
            },
          ));
        },
      );

  TaskEither<ImportError, ExportDataPayload> import({
    required String path,
  }) =>
      TaskEither.Do(
        ($) async {
          final json = await importer(path);
          final data = $(TaskEither.fromEither(tryDecodeData(data: json)));

          return data;
        },
      );
}
