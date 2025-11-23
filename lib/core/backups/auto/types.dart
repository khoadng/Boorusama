class AutoBackupManifest {
  const AutoBackupManifest({
    required this.backups,
  });

  factory AutoBackupManifest.fromJson(Map<String, dynamic> json) {
    return AutoBackupManifest(
      backups: (json['backups'] as List? ?? [])
          .map((e) => AutoBackupEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<AutoBackupEntry> backups;

  Map<String, dynamic> toJson() => {
    'backups': backups.map((e) => e.toJson()).toList(),
  };

  AutoBackupManifest copyWith({
    List<AutoBackupEntry>? backups,
  }) {
    return AutoBackupManifest(
      backups: backups ?? this.backups,
    );
  }
}

class AutoBackupEntry {
  const AutoBackupEntry({
    required this.fileName,
    required this.createdAt,
    required this.fileSize,
  });

  factory AutoBackupEntry.fromJson(Map<String, dynamic> json) {
    return AutoBackupEntry(
      fileName: switch (json['fileName']) {
        final String v => v,
        _ => '',
      },
      createdAt: switch (json['createdAt']) {
        final String v when DateTime.tryParse(v) != null => DateTime.parse(v),
        _ => DateTime.fromMillisecondsSinceEpoch(0),
      },
      fileSize: switch (json['fileSize']) {
        final int v => v,
        _ => 0,
      },
    );
  }

  final String fileName;
  final DateTime createdAt;
  final int fileSize;

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'createdAt': createdAt.toIso8601String(),
    'fileSize': fileSize,
  };
}

abstract class AutoBackupRepository {
  Future<String> getBackupDirectoryPath(String? userSelectedPath);
  Future<AutoBackupManifest> loadManifest(String backupDirPath);
  Future<void> saveManifest(String backupDirPath, AutoBackupManifest manifest);
  Future<void> deleteFile(String filePath);
  List<String> listZipFiles(String backupDirPath);
  bool fileExists(String filePath);
  Future<int> getFileSize(String filePath);
}
