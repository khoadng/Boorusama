import '../flow/plan.dart';
import 'status.dart';

final class ReleasePlayDraftStatusService {
  const ReleasePlayDraftStatusService();

  ReleaseFlowStepStatus status({
    required PlayReleaseStatus status,
    required String track,
    required String versionName,
    required int versionCode,
    required String releaseNotesLanguage,
    required String releaseNotesText,
  }) {
    if (_hasMatchingRelease(
      status.production,
      versionName: versionName,
      versionCode: versionCode,
      releaseNotesLanguage: releaseNotesLanguage,
      releaseNotesText: releaseNotesText,
      requireReleaseNotes: false,
    )) {
      return ReleaseFlowStepStatus.complete;
    }

    final playTrack = status.trackByName(track);
    if (playTrack != null &&
        _hasMatchingRelease(
          playTrack,
          versionName: versionName,
          versionCode: versionCode,
          releaseNotesLanguage: releaseNotesLanguage,
          releaseNotesText: releaseNotesText,
          requireReleaseNotes: true,
        )) {
      return ReleaseFlowStepStatus.waitingManualPublish;
    }

    return ReleaseFlowStepStatus.pending;
  }

  bool isDone({
    required PlayReleaseStatus status,
    required String track,
    required String versionName,
    required int versionCode,
    required String releaseNotesLanguage,
    required String releaseNotesText,
  }) {
    return this.status(
          status: status,
          track: track,
          versionName: versionName,
          versionCode: versionCode,
          releaseNotesLanguage: releaseNotesLanguage,
          releaseNotesText: releaseNotesText,
        ) !=
        ReleaseFlowStepStatus.pending;
  }

  bool _hasMatchingRelease(
    PlayTrackStatus track, {
    required String versionName,
    required int versionCode,
    required String releaseNotesLanguage,
    required String releaseNotesText,
    required bool requireReleaseNotes,
  }) {
    return track.releases.any((release) {
      if (release.name != versionName ||
          !release.versionCodes.contains(versionCode)) {
        return false;
      }

      if (!requireReleaseNotes) return true;

      return release.releaseNotes.any((note) {
        return note.language == releaseNotesLanguage &&
            note.text.trim() == releaseNotesText.trim();
      });
    });
  }
}
