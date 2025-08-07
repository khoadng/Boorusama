// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:version/version.dart';

// Project imports:
import '../types/types.dart';

class DataBackupConverter {
  DataBackupConverter({
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

  String encodeSingle(Map<String, dynamic> item) => encode(payload: [item]);

  T decodeSingle<T>(String data, T Function(Map<String, dynamic>) parser) {
    final payload = decode(data: data);
    if (payload.data.isEmpty) throw Exception('No data found in payload');
    return parser(payload.data.first as Map<String, dynamic>);
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

  return jsonEncode(data);
}

ExportDataPayload decodeData({required String data}) {
  late final Map<String, dynamic> json;

  json = jsonDecode(data) as Map<String, dynamic>;

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
}
