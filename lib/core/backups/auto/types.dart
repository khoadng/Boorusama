// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../foundation/platform.dart';

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

enum AutoBackupFrequency {
  daily(Duration(days: 1)),
  weekly(Duration(days: 7));

  const AutoBackupFrequency(this.duration);

  factory AutoBackupFrequency.parse(dynamic value) => switch (value) {
    'daily' => AutoBackupFrequency.daily,
    'weekly' => AutoBackupFrequency.weekly,
    _ => AutoBackupFrequency.weekly,
  };

  final Duration duration;
}

class AutoBackupSettings extends Equatable {
  const AutoBackupSettings({
    this.enabled = false,
    this.frequency = AutoBackupFrequency.weekly,
    this.maxBackups = 3,
    this.userSelectedPath,
    this.lastBackupTime,
  });

  factory AutoBackupSettings.parse(dynamic value) => switch (value) {
    final Map<String, dynamic> json => AutoBackupSettings(
      enabled: json['enabled'] as bool? ?? false,
      frequency: AutoBackupFrequency.parse(json['frequency']),
      maxBackups: json['maxBackups'] as int? ?? 5,
      userSelectedPath: json['userSelectedPath'] as String?,
      lastBackupTime: json['lastBackupTime'] != null
          ? DateTime.parse(json['lastBackupTime'] as String)
          : null,
    ),
    _ => disabled,
  };

  static const disabled = AutoBackupSettings();
  static const defaultValue = disabled;

  final bool enabled;
  final AutoBackupFrequency frequency;
  final int maxBackups;
  final String? userSelectedPath;
  final DateTime? lastBackupTime;

  bool get shouldBackup {
    // Not enabled - no backup
    if (!enabled) return false;

    // Android requires user-selected path
    if (isAndroid() && (userSelectedPath?.isEmpty ?? true)) {
      return false;
    }

    // First backup - always needed
    if (lastBackupTime == null) return true;

    // Check if enough time has passed
    final elapsed = DateTime.now().difference(lastBackupTime!);
    return elapsed >= frequency.duration;
  }

  AutoBackupSettings copyWith({
    bool? enabled,
    AutoBackupFrequency? frequency,
    int? maxBackups,
    String? Function()? userSelectedPath,
    DateTime? Function()? lastBackupTime,
  }) {
    return AutoBackupSettings(
      enabled: enabled ?? this.enabled,
      frequency: frequency ?? this.frequency,
      maxBackups: maxBackups ?? this.maxBackups,
      userSelectedPath: userSelectedPath != null
          ? userSelectedPath()
          : this.userSelectedPath,
      lastBackupTime: lastBackupTime != null
          ? lastBackupTime()
          : this.lastBackupTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'frequency': frequency.name,
    'maxBackups': maxBackups,
    'userSelectedPath': ?userSelectedPath,
    'lastBackupTime': ?lastBackupTime?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    enabled,
    frequency,
    maxBackups,
    userSelectedPath,
    lastBackupTime,
  ];
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
