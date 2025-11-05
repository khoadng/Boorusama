// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:foundation/foundation.dart';

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

  ExportDataPayload decode({required String data, BuildContext? uiContext}) {
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

ExportDataPayload decodeData({required String data, BuildContext? uiContext}) =>
    tryDecodeJson(data).fold(
      (_) => throw const InvalidBackupFormatException(),
      (json) => switch (json) {
        {
          'version': final int version,
          'data': final List<dynamic> payload,
        } =>
          ExportDataPayload(
            version: version,
            exportDate: switch (json['date']) {
              final String dateStr => DateTime.tryParse(dateStr),
              _ => null,
            },
            exportVersion: Version.tryParse(json['exportVersion']),
            data: payload,
          ),
        final List<dynamic> legacyList => ExportDataPayload.legacy(
          data: legacyList,
        ),
        final Map<String, dynamic> legacyMap => ExportDataPayload.legacy(
          data: [legacyMap],
        ),
        _ => throw const InvalidBackupFormatException(),
      },
    );
