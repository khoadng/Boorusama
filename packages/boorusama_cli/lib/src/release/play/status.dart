final class PlayReleaseStatus {
  const PlayReleaseStatus({
    required this.track,
    required this.production,
    required this.tracks,
    required this.defaultLanguage,
    required this.contactEmail,
    required this.contactWebsite,
    required this.contactPhone,
    required this.listingLanguages,
  });

  final String track;
  final PlayTrackStatus production;
  final List<PlayTrackStatus> tracks;
  final String? defaultLanguage;
  final String? contactEmail;
  final String? contactWebsite;
  final String? contactPhone;
  final List<String> listingLanguages;

  int? get productionMaxVersionCode => production.maxVersionCode;
}

final class PlayTrackStatus {
  const PlayTrackStatus({
    required this.name,
    required this.releases,
  });

  final String name;
  final List<PlayTrackRelease> releases;

  int? get maxVersionCode {
    final codes = releases.expand((release) => release.versionCodes);
    if (codes.isEmpty) return null;
    return codes.reduce((value, element) => value > element ? value : element);
  }
}

final class PlayTrackRelease {
  const PlayTrackRelease({
    required this.name,
    required this.status,
    required this.versionCodes,
    required this.releaseNotesCount,
    required this.userFraction,
  });

  final String? name;
  final String? status;
  final List<int> versionCodes;
  final int releaseNotesCount;
  final double? userFraction;
}
