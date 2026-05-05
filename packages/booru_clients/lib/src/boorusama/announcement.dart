// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:coreutils/coreutils.dart';

class BoorusamaAnnouncementIndex {
  const BoorusamaAnnouncementIndex({
    required this.schemaVersion,
    required this.files,
  });

  factory BoorusamaAnnouncementIndex.fromJson(Map<String, dynamic> json) {
    return BoorusamaAnnouncementIndex(
      schemaVersion: switch (json['schema_version']) {
        final int value => value,
        final String value => int.tryParse(value) ?? 0,
        _ => 0,
      },
      files: BoorusamaAnnouncementIndexFiles.fromJson(
        _asMap(json['files']),
      ),
    );
  }

  final int schemaVersion;
  final BoorusamaAnnouncementIndexFiles files;

  bool get isSupported => schemaVersion == 1;
}

class BoorusamaAnnouncementIndexFiles {
  const BoorusamaAnnouncementIndexFiles({
    required this.global,
    required this.boorus,
    required this.hosts,
  });

  factory BoorusamaAnnouncementIndexFiles.fromJson(Map<String, dynamic> json) {
    return BoorusamaAnnouncementIndexFiles(
      global: json['global'] as String?,
      boorus: _stringMap(json['boorus']),
      hosts: _stringMap(json['hosts']),
    );
  }

  final String? global;
  final Map<String, String> boorus;
  final Map<String, String> hosts;
}

class BoorusamaAnnouncementFile {
  const BoorusamaAnnouncementFile({
    required this.announcements,
  });

  factory BoorusamaAnnouncementFile.fromJson(Map<String, dynamic> json) {
    return BoorusamaAnnouncementFile(
      announcements: switch (json['announcements']) {
        final List<dynamic> value =>
          value
              .map(_asMap)
              .where((entry) => entry.isNotEmpty)
              .map(BoorusamaAnnouncement.fromJson)
              .toList(),
        _ => const [],
      },
    );
  }

  final List<BoorusamaAnnouncement> announcements;
}

class BoorusamaAnnouncement {
  const BoorusamaAnnouncement({
    required this.id,
    required this.priority,
    required this.severity,
    required this.startsAt,
    required this.endsAt,
    required this.appVersions,
    required this.platforms,
    required this.builds,
    required this.channels,
    required this.modes,
    required this.devices,
    required this.languages,
    required this.os,
    required this.contentHtml,
    required this.actions,
    required this.dismissible,
  });

  factory BoorusamaAnnouncement.fromJson(Map<String, dynamic> json) {
    return BoorusamaAnnouncement(
      id: json['id'] as String? ?? '',
      priority: switch (json['priority']) {
        final int value => value,
        final String value => int.tryParse(value) ?? 0,
        _ => 0,
      },
      severity: BoorusamaAnnouncementSeverity.fromJson(json['severity']),
      startsAt: _dateTimeFromJson(json['starts_at']),
      endsAt: _dateTimeFromJson(json['ends_at']),
      appVersions: BoorusamaAnnouncementVersionRange.tryParse(
        json['app_versions'],
      ),
      platforms: switch (json['platforms']) {
        final List<dynamic> value => value.whereType<String>().toSet(),
        _ => null,
      },
      builds: switch (json['builds']) {
        final List<dynamic> value => value.whereType<String>().toSet(),
        _ => null,
      },
      channels: switch (json['channels']) {
        final List<dynamic> value => value.whereType<String>().toSet(),
        _ => null,
      },
      modes: switch (json['modes']) {
        final List<dynamic> value => value.whereType<String>().toSet(),
        _ => null,
      },
      devices: switch (json['devices']) {
        final List<dynamic> value => value.whereType<String>().toSet(),
        _ => null,
      },
      languages: switch (json['languages']) {
        final List<dynamic> value => value.whereType<String>().toSet(),
        _ => null,
      },
      os: BoorusamaAnnouncementOsTargets.tryParse(json['os']),
      contentHtml: json['content_html'] as String? ?? '',
      dismissible: switch (json['dismissible']) {
        final bool value => value,
        _ => true,
      },
      actions: switch (json['actions']) {
        final List<dynamic> value =>
          value
              .map(_asMap)
              .where((entry) => entry.isNotEmpty)
              .map(BoorusamaAnnouncementAction.fromJson)
              .where(
                (action) => action.label.isNotEmpty && action.url.isNotEmpty,
              )
              .toList(),
        _ => const [],
      },
    );
  }

  final String id;
  final int priority;
  final BoorusamaAnnouncementSeverity severity;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final BoorusamaAnnouncementVersionRange? appVersions;
  final Set<String>? platforms;
  final Set<String>? builds;
  final Set<String>? channels;
  final Set<String>? modes;
  final Set<String>? devices;
  final Set<String>? languages;
  final BoorusamaAnnouncementOsTargets? os;
  final String contentHtml;
  final List<BoorusamaAnnouncementAction> actions;
  final bool dismissible;
}

class BoorusamaAnnouncementOsTargets {
  const BoorusamaAnnouncementOsTargets({
    required this.rules,
  });

  static BoorusamaAnnouncementOsTargets? tryParse(dynamic value) {
    final json = _tryMap(value);
    if (json == null) return null;

    return BoorusamaAnnouncementOsTargets(
      rules: {
        for (final entry in json.entries)
          if (entry.key.trim().isNotEmpty && _tryMap(entry.value) != null)
            entry.key.toLowerCase(): BoorusamaAnnouncementOsRule.fromJson(
              _tryMap(entry.value)!,
            ),
      },
    );
  }

  final Map<String, BoorusamaAnnouncementOsRule> rules;
}

class BoorusamaAnnouncementOsRule {
  const BoorusamaAnnouncementOsRule({
    required this.sdk,
    required this.version,
    required this.distros,
    required this.versionIds,
    required this.browsers,
  });

  factory BoorusamaAnnouncementOsRule.fromJson(Map<String, dynamic> json) {
    return BoorusamaAnnouncementOsRule(
      sdk: BoorusamaAnnouncementIntRange.tryParse(json['sdk']),
      version: BoorusamaAnnouncementVersionRange.tryParse(json['version']),
      distros: _stringSet(json['distros']),
      versionIds: _stringSet(json['version_ids']),
      browsers: _stringSet(json['browsers']),
    );
  }

  final BoorusamaAnnouncementIntRange? sdk;
  final BoorusamaAnnouncementVersionRange? version;
  final Set<String>? distros;
  final Set<String>? versionIds;
  final Set<String>? browsers;
}

class BoorusamaAnnouncementAction {
  const BoorusamaAnnouncementAction({
    required this.label,
    required this.url,
  });

  factory BoorusamaAnnouncementAction.fromJson(Map<String, dynamic> json) {
    return BoorusamaAnnouncementAction(
      label: json['label'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  final String label;
  final String url;
}

enum BoorusamaAnnouncementSeverity {
  info,
  warning,
  critical;

  static BoorusamaAnnouncementSeverity fromJson(dynamic value) {
    return switch (value) {
      'warning' => BoorusamaAnnouncementSeverity.warning,
      'critical' => BoorusamaAnnouncementSeverity.critical,
      _ => BoorusamaAnnouncementSeverity.info,
    };
  }
}

class BoorusamaAnnouncementVersionRange {
  const BoorusamaAnnouncementVersionRange({
    required this.min,
    required this.max,
  });

  static BoorusamaAnnouncementVersionRange? tryParse(dynamic value) {
    if (value == null) return null;

    final json = _asMap(value);
    if (json.isEmpty) return null;

    return BoorusamaAnnouncementVersionRange(
      min: _versionFromJson(json['min']),
      max: _versionFromJson(json['max']),
    );
  }

  final Version? min;
  final Version? max;

  bool contains(Version version) {
    final min = this.min;
    if (min != null && version < min) return false;

    final max = this.max;
    if (max != null && version > max) return false;

    return true;
  }
}

class BoorusamaAnnouncementIntRange {
  const BoorusamaAnnouncementIntRange({
    required this.min,
    required this.max,
  });

  static BoorusamaAnnouncementIntRange? tryParse(dynamic value) {
    if (value == null) return null;

    final json = _asMap(value);
    if (json.isEmpty) return null;

    return BoorusamaAnnouncementIntRange(
      min: _intFromJson(json['min']),
      max: _intFromJson(json['max']),
    );
  }

  final int? min;
  final int? max;

  bool contains(int value) {
    final min = this.min;
    if (min != null && value < min) return false;

    final max = this.max;
    if (max != null && value > max) return false;

    return true;
  }
}

Map<String, dynamic> boorusamaJsonMapFromResponseData(dynamic data) {
  return switch (data) {
    final Map<String, dynamic> value => value,
    final Map<dynamic, dynamic> value => value.map(
      (key, value) => MapEntry(key.toString(), value),
    ),
    final String value => _asMap(jsonDecode(value)),
    _ => const {},
  };
}

Map<String, dynamic> _asMap(dynamic value) {
  return switch (value) {
    final Map<String, dynamic> map => map,
    final Map<dynamic, dynamic> map => map.map(
      (key, value) => MapEntry(key.toString(), value),
    ),
    _ => const {},
  };
}

Map<String, dynamic>? _tryMap(dynamic value) {
  return switch (value) {
    final Map<String, dynamic> map => map,
    final Map<dynamic, dynamic> map => map.map(
      (key, value) => MapEntry(key.toString(), value),
    ),
    _ => null,
  };
}

Set<String>? _stringSet(dynamic value) {
  return switch (value) {
    final List<dynamic> list => list.whereType<String>().toSet(),
    _ => null,
  };
}

Map<String, String> _stringMap(dynamic value) {
  final map = _asMap(value);

  return {
    for (final entry in map.entries)
      if (entry.value case final String path) entry.key: path,
  };
}

DateTime? _dateTimeFromJson(dynamic value) {
  return switch (value) {
    final String raw when raw.isNotEmpty => DateTime.tryParse(raw)?.toUtc(),
    _ => null,
  };
}

Version? _versionFromJson(dynamic value) {
  return switch (value) {
    final String raw when raw.isNotEmpty => Version.tryParse(raw),
    _ => null,
  };
}

int? _intFromJson(dynamic value) {
  return switch (value) {
    final int raw => raw,
    final String raw when raw.isNotEmpty => int.tryParse(raw),
    _ => null,
  };
}
