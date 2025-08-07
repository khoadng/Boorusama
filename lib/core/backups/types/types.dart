// Package imports:
import 'package:version/version.dart';

const kInvalidLocationMessage =
    'Cannot export to this location, try using "Download" or "Documents" folder. Create one if it does not exist.';

class ExportDataPayload {
  ExportDataPayload({
    required this.version,
    required this.exportDate,
    required this.data,
    required this.exportVersion,
  });

  final int version;
  final DateTime exportDate;
  final Version? exportVersion;
  final List<dynamic> data;

  Map<String, dynamic> toJson() => {
    'version': version,
    if (exportVersion != null) 'exportVersion': exportVersion.toString(),
    'date': exportDate.toIso8601String(),
    'data': data,
  };
}
