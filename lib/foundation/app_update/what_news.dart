// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:hive/hive.dart';
import 'package:version/version.dart';

// Project imports:
import 'package:boorusama/dart.dart';
import 'package:boorusama/time.dart';

const kChangelogKey = 'changelog';

const String _assetUrl = 'CHANGELOG.md';

sealed class ReleaseVersion {
  const ReleaseVersion();

  factory ReleaseVersion.fromText(String? text) =>
      switch (text?.toLowerCase()) {
        String s => s.startsWith('unreleased')
            ? Unreleased.fromText(s)
            : Official(Version.parse(s)),
        _ => Invalid(),
      };

  String? getChangelogKey() => switch (this) {
        Unreleased u =>
          '${kChangelogKey}_unreleased_${u.lastUpdated?.toIso8601String() ?? 'no-date'}_seen',
        Official o =>
          '${kChangelogKey}_${o.version.withoutPreRelease().toString()}_seen',
        Invalid _ => null,
      };

  @override
  String toString() => switch (this) {
        Unreleased _ => 'unreleased',
        Official o => o.version.toString(),
        Invalid _ => 'invalid',
      };
}

class Unreleased extends ReleaseVersion {
  const Unreleased(this.lastUpdated);

  // unreleased-2000.1.1
  factory Unreleased.fromText(String text) {
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

    return Unreleased(
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
  ReleaseVersion version,
  String content,
});

extension VersionX on Version {
  Version withoutPreRelease() => Version(major, minor, patch);
}

Future<ChangelogData> loadLatestChangelogFromAssets() async {
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

  return (
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
}

bool shouldShowChangelogDialog(
  Box<String> dataBox,
  ReleaseVersion targetVersion,
) {
  final key = targetVersion.getChangelogKey();

  // Invalid version
  if (key == null) return false;

  final value = dataBox.get(key);

  // Already seen
  if (value != null) return false;

  return true;
}
