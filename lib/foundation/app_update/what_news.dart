// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:hive/hive.dart';
import 'package:version/version.dart';

// Project imports:
import 'package:boorusama/foundation/package_info.dart';

const kChangelogKey = 'changelog';

const String _assetUrl = 'CHANGELOG.md';

typedef ChangelogData = ({
  Version version,
  String content,
});

Future<ChangelogData> loadLatestChangelogFromAssets() async {
  final text = await rootBundle.loadString(_assetUrl);

  // parse the md file until encountering the first empty line
  final lines = text.split('\n');
  final buffer = StringBuffer();
  final version = Version.parse(lines[0].substring(2).trim());

  for (var i = 1; i < lines.length; i++) {
    final line = lines[i];
    if (line.isEmpty) {
      break;
    }

    buffer.writeln(line);
  }

  return (
    version: version,
    content: buffer.toString(),
  );
}

String getChangelogKey(Version version) =>
    '${kChangelogKey}_${version.toString()}_seen';

Future<void> markChangelogAsSeen(
  Version version,
  Box<String> dataBox,
) async {
  final key = getChangelogKey(version);
  final currentTime = DateTime.now();
  await dataBox.put(key, currentTime.toIso8601String());
}

Future<bool> shouldShowChangelogDialog(
  PackageInfo packageInfo,
  Box<String> dataBox,
  Version targetVersion,
) async {
  final currentVersion = Version.parse(packageInfo.version);

  // check if the current version is the target version
  if (currentVersion.major != targetVersion.major ||
      currentVersion.minor != targetVersion.minor ||
      currentVersion.patch != targetVersion.patch) {
    return false;
  }

  final key = getChangelogKey(currentVersion);
  final value = dataBox.get(key);

  if (value != null) {
    return false;
  }

  return true;
}
