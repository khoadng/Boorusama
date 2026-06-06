import 'dart:io';

import 'status.dart';

abstract interface class PlayReleaseRepository {
  Future<PlayReleaseStatus> fetchStatus();

  Future<int> createDraftRelease(PlayDraftRelease release);
}

final class PlayDraftRelease {
  const PlayDraftRelease({
    required this.bundle,
    required this.track,
    required this.name,
    required this.releaseNotes,
  });

  final File bundle;
  final String track;
  final String name;
  final List<PlayReleaseNote> releaseNotes;
}

final class PlayReleaseNote {
  const PlayReleaseNote({
    required this.language,
    required this.text,
  });

  final String language;
  final String text;
}
