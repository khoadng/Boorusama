// Package imports:
import 'package:equatable/equatable.dart';

enum AutoBackupFrequency {
  daily(Duration(days: 1)),
  weekly(Duration(days: 7));

  const AutoBackupFrequency(this.duration);
  final Duration duration;
}

class AutoBackupSettings extends Equatable {
  const AutoBackupSettings({
    this.enabled = false,
    this.frequency = AutoBackupFrequency.weekly,
    this.maxBackups = 2,
    this.userSelectedPath,
    this.lastBackupTime,
  });

  factory AutoBackupSettings.fromJson(Map<String, dynamic> json) {
    return AutoBackupSettings(
      enabled: json['enabled'] as bool? ?? false,
      frequency: AutoBackupFrequency.values.firstWhere(
        (f) => f.name == json['frequency'],
        orElse: () => AutoBackupFrequency.weekly,
      ),
      maxBackups: json['maxBackups'] as int? ?? 5,
      userSelectedPath: json['userSelectedPath'] as String?,
      lastBackupTime: json['lastBackupTime'] != null
          ? DateTime.parse(json['lastBackupTime'] as String)
          : null,
    );
  }

  static const disabled = AutoBackupSettings(
    enabled: false,
    frequency: AutoBackupFrequency.weekly,
    maxBackups: 5,
    userSelectedPath: null,
    lastBackupTime: null,
  );

  final bool enabled;
  final AutoBackupFrequency frequency;
  final int maxBackups;
  final String? userSelectedPath;
  final DateTime? lastBackupTime;

  bool get shouldBackup {
    if (!enabled) return false;
    if (lastBackupTime == null) return true;

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
    if (userSelectedPath != null) 'userSelectedPath': userSelectedPath,
    if (lastBackupTime != null)
      'lastBackupTime': lastBackupTime!.toIso8601String(),
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
