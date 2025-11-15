// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

const kChangelogKey = 'changelog';
const kPreviousVersionKey = 'changelog_previous_version';

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

class ChangelogData extends Equatable {
  const ChangelogData({
    required this.previousVersion,
    required this.version,
    required this.content,
  });

  final ReleaseVersion? previousVersion;
  final ReleaseVersion version;
  final String content;

  bool isSignificantUpdate() => switch ((previousVersion, version)) {
    // only check major and minor versions of official releases
    (final Official prev, final Official curr) =>
      prev.version.minor < curr.version.minor ||
          prev.version.major < curr.version.major,
    _ => false,
  };

  @override
  List<Object?> get props => [previousVersion, version, content];
}

extension VersionX on Version {
  Version withoutPreRelease() => Version(major, minor, patch);
}

abstract class ChangelogRepository {
  Future<ChangelogData> loadLatestChangelog();
  Future<String> loadFullChangelog();
  Future<void> markChangelogAsSeen(ReleaseVersion version);
  Future<bool> shouldShowChangelog(ReleaseVersion version);
}
