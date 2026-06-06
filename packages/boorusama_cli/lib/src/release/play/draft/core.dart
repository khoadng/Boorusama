import 'dart:io';

import '../../../io/process_runner.dart';
import 'metadata.dart';
import '../repository.dart';

final class PlayDraftReleaseService {
  const PlayDraftReleaseService({
    required this.repository,
    this.track = 'production',
  });

  final PlayReleaseRepository repository;
  final String track;

  Future<PlayDraftReleaseResult> createDraft({
    required File bundle,
    required PlayReleaseMetadata metadata,
  }) async {
    if (!bundle.existsSync()) {
      throw ProcessFailure('AAB does not exist: ${bundle.path}');
    }

    final versionCode = await repository.createDraftRelease(
      PlayDraftRelease(
        bundle: bundle,
        track: track,
        name: metadata.name,
        releaseNotes: [metadata.notes],
      ),
    );

    return PlayDraftReleaseResult(
      track: track,
      versionName: metadata.name,
      versionCode: versionCode,
    );
  }
}

final class PlayDraftReleaseResult {
  const PlayDraftReleaseResult({
    required this.track,
    required this.versionName,
    required this.versionCode,
  });

  final String track;
  final String versionName;
  final int versionCode;
}
