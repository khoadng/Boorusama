// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:foundation/foundation.dart';
import 'package:hive_ce/hive.dart';

const kChangelogKey = 'changelog';
const kPreviousVersionKey = 'changelog_previous_version';

const _assetUrl = 'CHANGELOG.md';

sealed class ReleaseVersion {
  const ReleaseVersion();

  factory ReleaseVersion.fromText(String? text) => switch (text
      ?.toLowerCase()) {
    final String s when s.startsWith('prereleased') => Prereleased.fromText(s),
    final String s => switch (Version.tryParse(s)) {
      final v? => Official(v),
      _ => Invalid(),
    },
    _ => Invalid(),
  };

  String? getChangelogKey() => switch (this) {
    final Prereleased u =>
      '${kChangelogKey}_prereleased_${u.lastUpdated?.toIso8601String() ?? 'no-date'}_seen',
    final Official o =>
      '${kChangelogKey}_${o.version.withoutPreRelease()}_seen',
    Invalid _ => null,
  };

  static ReleaseVersion? getVersionFromChangelogKey(String key) {
    return switch (key.split('_')) {
      [_, 'prereleased', final dateStr, ...] => Prereleased(
        DateTime.tryParse(dateStr),
      ),
      [_, final versionStr, ...] => switch (Version.tryParse(versionStr)) {
        final v? => Official(v),
        _ => null,
      },
      _ => null,
    };
  }

  @override
  String toString() => switch (this) {
    Prereleased _ => 'pre-released',
    final Official o => o.version.toString(),
    Invalid _ => 'invalid',
  };
}

class Prereleased extends ReleaseVersion {
  const Prereleased(this.lastUpdated);

  // prereleased-2000.1.1
  factory Prereleased.fromText(String text) {
    final parts = text.split('-');
    final dateStrings = parts.getOrNull(1)?.split('.');
    final year = dateStrings?.getOrNull(0);
    final month = dateStrings?.getOrNull(1);
    final day = dateStrings?.getOrNull(2);
    final date = year != null && month != null && day != null
        ? DateTime(
            int.tryParse(year) ?? 0,
            int.tryParse(month) ?? 0,
            int.tryParse(day) ?? 0,
          )
        : null;

    return Prereleased(
      date,
    );
  }

  final DateTime? lastUpdated;
}

class Official extends ReleaseVersion {
  const Official(this.version);

  final Version version;
}

class Invalid extends ReleaseVersion {}

typedef ChangelogData = ({
  ReleaseVersion? previousVersion,
  ReleaseVersion version,
  String content,
});

extension VersionX on Version {
  Version withoutPreRelease() => Version(major, minor, patch);
}

Future<ChangelogData> loadLatestChangelogFromAssets(
  Box<String> dataBox,
) async {
  final text = await rootBundle.loadString(_assetUrl);

  // parse the md file until encountering the first empty line
  final lines = text.split('\n');
  final buffer = StringBuffer();
  final versionText = lines[0].substring(2).trim().toLowerCase();

  for (var i = 1; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().isEmpty) {
      break;
    }

    buffer.writeln(line);
  }

  final previousVersionKey = dataBox.get(kPreviousVersionKey);
  final previousVersion = previousVersionKey != null
      ? ReleaseVersion.getVersionFromChangelogKey(previousVersionKey)
      : null;

  return (
    previousVersion: previousVersion,
    version: ReleaseVersion.fromText(versionText),
    content: buffer.toString(),
  );
}

Future<void> markChangelogAsSeen(
  ReleaseVersion version,
  Box<String> dataBox,
) async {
  final key = version.getChangelogKey();

  if (key == null) return;

  final currentTime = DateTime.now().dateOnly();
  await dataBox.put(key, currentTime.toIso8601String());
  await dataBox.put(kPreviousVersionKey, key);
}

Future<bool> shouldShowChangelogDialog(
  Box<String> dataBox,
  ReleaseVersion targetVersion,
) async {
  final key = targetVersion.getChangelogKey();

  // Invalid version
  if (key == null) return false;

  final value = dataBox.get(key);

  // Already seen
  if (value != null) {
    // Check if previous version is set, if not, we will set it
    if (dataBox.get(kPreviousVersionKey) == null) {
      await dataBox.put(kPreviousVersionKey, key);
    }

    return false;
  }

  return true;
}
