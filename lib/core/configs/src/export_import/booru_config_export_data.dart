// Package imports:

// Package imports:
import 'package:version/version.dart';

// Project imports:
import 'package:boorusama/core/backups/types.dart';
import '../booru_config.dart';

class BooruConfigExportData {
  BooruConfigExportData({
    required this.data,
    required this.exportData,
  });

  int get version => exportData.version;
  DateTime get exportDate => exportData.exportDate;
  Version? get exportVersion => exportData.exportVersion;
  final List<BooruConfig> data;
  final ExportDataPayload exportData;
}
