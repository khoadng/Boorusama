// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import 'types.dart';

const _assetUrl = 'CHANGELOG.md';

class ChangelogRepositoryImpl implements ChangelogRepository {
  const ChangelogRepositoryImpl(this._dataBox);

  final Box<String> _dataBox;

  @override
  Future<ChangelogData> loadLatestChangelog() async {
    final text = await _loadData();

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

    final previousVersionKey = _dataBox.get(kPreviousVersionKey);
    final previousVersion = previousVersionKey != null
        ? ReleaseVersion.getVersionFromChangelogKey(previousVersionKey)
        : null;

    return ChangelogData(
      previousVersion: previousVersion,
      version: ReleaseVersion.fromText(versionText),
      content: buffer.toString(),
    );
  }

  @override
  Future<String> loadFullChangelog() => _loadData();

  @override
  Future<void> markChangelogAsSeen(ReleaseVersion version) async {
    final key = version.getChangelogKey();

    if (key == null) return;

    final currentTime = DateTime.now().dateOnly();
    await _dataBox.put(key, currentTime.toIso8601String());
    await _dataBox.put(kPreviousVersionKey, key);
  }

  @override
  Future<bool> shouldShowChangelog(ReleaseVersion version) async {
    final key = version.getChangelogKey();

    // Invalid version
    if (key == null) return false;

    final value = _dataBox.get(key);

    // Already seen
    if (value != null) {
      // Check if previous version is set, if not, we will set it
      if (_dataBox.get(kPreviousVersionKey) == null) {
        await _dataBox.put(kPreviousVersionKey, key);
      }

      return false;
    }

    return true;
  }

  Future<String> _loadData() => rootBundle.loadString(_assetUrl);
}
