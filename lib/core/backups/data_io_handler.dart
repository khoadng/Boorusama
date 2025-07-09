// Dart imports:
import 'dart:io';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../foundation/info/device_info.dart';
import '../../foundation/path.dart';
import '../../foundation/permissions.dart';
import 'data_converter.dart';
import 'types.dart';

class DataIOHandler {
  DataIOHandler({
    required this.permissionChecker,
    required this.permissionRequester,
    required this.exporter,
    required this.importer,
    required this.converter,
  });

  factory DataIOHandler.file({
    required DeviceInfo deviceInfo,
    required String prefixName,
    required DataBackupConverter converter,
  }) => DataIOHandler(
    converter: converter,
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
  final DataBackupConverter converter;

  TaskEither<ExportError, Unit> export({
    required List<dynamic> data,
    required String path,
  }) => TaskEither.Do(
    ($) async {
      final status = await permissionChecker();

      if (status != PermissionStatus.granted) {
        final status = await permissionRequester();

        if (status != PermissionStatus.granted) {
          return $(TaskEither.left(const StoragePermissionDenied()));
        }
      }

      final jsonString = await $(
        converter.tryEncode(payload: data).toTaskEither(),
      );

      return $(
        TaskEither.tryCatch(
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
        ),
      );
    },
  );

  TaskEither<ImportError, ExportDataPayload> import({
    required String path,
  }) => TaskEither.Do(
    ($) async {
      final json = await importer(path);
      final data = await $(converter.tryDecode(data: json).toTaskEither());

      return data;
    },
  );
}
