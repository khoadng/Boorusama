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

  int? get maxVersionCode {
    final codes = tracks
        .map((track) => track.maxVersionCode)
        .whereType<int>()
        .toList();
    if (codes.isEmpty) return null;
    return codes.reduce((value, element) => value > element ? value : element);
  }

  PlayTrackStatus? get maxVersionCodeTrack {
    PlayTrackStatus? maxTrack;
    var maxCode = -1;
    for (final track in tracks) {
      final trackMax = track.maxVersionCode;
      if (trackMax != null && trackMax > maxCode) {
        maxCode = trackMax;
        maxTrack = track;
      }
    }
    return maxTrack;
  }

  PlayTrackStatus? trackByName(String name) {
    for (final track in tracks) {
      if (track.name == name) return track;
    }
    return null;
  }
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
    required this.releaseNotes,
    required this.userFraction,
  });

  final String? name;
  final String? status;
  final List<int> versionCodes;
  final int releaseNotesCount;
  final List<PlayReleaseNoteStatus> releaseNotes;
  final double? userFraction;
}

final class PlayReleaseNoteStatus {
  const PlayReleaseNoteStatus({
    required this.language,
    required this.text,
  });

  final String language;
  final String text;
}
