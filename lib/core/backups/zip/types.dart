// Project imports:
import '../types/backup_data_source.dart';

class BulkExportResult {
  const BulkExportResult({
    required this.success,
    required this.exported,
    required this.failed,
    required this.filePath,
  });

  final bool success;
  final List<String> exported;
  final List<String> failed;
  final String filePath;

  bool get hasFailures => failed.isNotEmpty;
  int get totalSources => exported.length + failed.length;
}

class ZipPreviewResult {
  const ZipPreviewResult({
    required this.manifest,
    required this.availableSources,
    required this.missingSources,
  });

  final BulkBackupManifest manifest;
  final List<BackupDataSource> availableSources;
  final List<String> missingSources;
}

class BulkBackupManifest {
  const BulkBackupManifest({
    required this.version,
    required this.appVersion,
    required this.exportDate,
    required this.sourceFiles,
    required this.failed,
  });

  factory BulkBackupManifest.fromJson(Map<String, dynamic> json) {
    return BulkBackupManifest(
      version: json['version'] as int,
      appVersion: json['appVersion'] as String?,
      exportDate: DateTime.parse(json['exportDate'] as String),
      sourceFiles: Map<String, String>.from(json['sourceFiles'] as Map? ?? {}),
      failed: List<String>.from(json['failed'] as List? ?? []),
    );
  }

  final int version;
  final String? appVersion;
  final DateTime exportDate;
  final Map<String, String> sourceFiles; // sourceId -> filename
  final List<String> failed;

  List<String> get sources => sourceFiles.keys.toList();

  Map<String, dynamic> toJson() => {
    'version': version,
    if (appVersion != null) 'appVersion': appVersion,
    'exportDate': exportDate.toIso8601String(),
    'sourceFiles': sourceFiles,
    'failed': failed,
  };
}

class BulkImportResult {
  const BulkImportResult({
    required this.success,
    required this.imported,
    required this.failed,
    required this.skipped,
  });

  final bool success;
  final List<String> imported;
  final List<String> failed;
  final List<String> skipped;

  bool get hasFailures => failed.isNotEmpty;
  int get totalProcessed => imported.length + failed.length + skipped.length;
}
