// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:version/version.dart';

// Project imports:
import 'types.dart';

class DataBackupConverter2 {
  DataBackupConverter2({
    required this.version,
    required this.exportVersion,
  });

  final int version;
  final Version? exportVersion;

  String encode({required List<dynamic> payload}) {
    return encodeData(
      version: version,
      exportDate: DateTime.now(),
      exportVersion: exportVersion,
      payload: payload,
    );
  }

  ExportDataPayload decode({required String data}) {
    return decodeData(data: data);
  }
}

String encodeData({
  required int version,
  required DateTime exportDate,
  required Version? exportVersion,
  required List<dynamic> payload,
}) {
  final data = ExportDataPayload(
    version: version,
    exportDate: exportDate,
    exportVersion: exportVersion,
    data: payload,
  ).toJson();

  try {
    return jsonEncode(data);
  } catch (e, st) {
    throw JsonEncodingError(error: e, stackTrace: st);
  }
}

ExportDataPayload decodeData({required String data}) {
  late final Map<String, dynamic> json;

  try {
    json = jsonDecode(data) as Map<String, dynamic>;
  } catch (e) {
    throw const ImportInvalidJson();
  }

  try {
    final version = json['version'] as int;
    final date = DateTime.parse(json['date'] as String);
    final exportVersion = json['exportVersion'] != null
        ? Version.parse(json['exportVersion'] as String)
        : null;
    final payload = json['data'] as List<dynamic>;

    return ExportDataPayload(
      version: version,
      exportDate: date,
      exportVersion: exportVersion,
      data: payload,
    );
  } catch (e) {
    throw const ImportInvalidJsonField();
  }
}
