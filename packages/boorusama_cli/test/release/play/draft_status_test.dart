import 'package:boorusama_cli/src/release/flow/plan.dart';
import 'package:boorusama_cli/src/release/play/draft_status.dart';
import 'package:boorusama_cli/src/release/play/status.dart';
import 'package:test/test.dart';

void main() {
  group('ReleasePlayDraftStatusService', () {
    test('is done when target track has matching version name and code', () {
      final status = _status(
        track: _track(
          'internal',
          releases: [
            _release(name: '4.5.0', versionCodes: [180]),
          ],
        ),
      );

      expect(
        const ReleasePlayDraftStatusService().status(
          status: status,
          track: 'internal',
          versionName: '4.5.0',
          versionCode: 180,
          releaseNotesLanguage: 'en-US',
          releaseNotesText: 'Release notes',
        ),
        ReleaseFlowStepStatus.waitingManualPublish,
      );
      expect(
        const ReleasePlayDraftStatusService().isDone(
          status: status,
          track: 'internal',
          versionName: '4.5.0',
          versionCode: 180,
          releaseNotesLanguage: 'en-US',
          releaseNotesText: 'Release notes',
        ),
        isTrue,
      );
    });

    test('is complete when production has the version live', () {
      final status = _status(
        production: _track(
          'production',
          releases: [
            _release(name: '4.5.0', versionCodes: [180], status: 'completed'),
          ],
        ),
        track: _track('internal'),
      );

      expect(
        const ReleasePlayDraftStatusService().status(
          status: status,
          track: 'internal',
          versionName: '4.5.0',
          versionCode: 180,
          releaseNotesLanguage: 'en-US',
          releaseNotesText: 'Different release notes are ignored in production',
        ),
        ReleaseFlowStepStatus.complete,
      );
    });

    test('is pending when version code is consumed by another release', () {
      final status = _status(
        track: _track(
          'internal',
          releases: [
            _release(name: '4.4.0', versionCodes: [180]),
          ],
        ),
      );

      expect(
        const ReleasePlayDraftStatusService().isDone(
          status: status,
          track: 'internal',
          versionName: '4.5.0',
          versionCode: 180,
          releaseNotesLanguage: 'en-US',
          releaseNotesText: 'Release notes',
        ),
        isFalse,
      );
    });

    test('is pending when matching release is on a different track', () {
      final status = _status(
        track: _track(
          'beta',
          releases: [
            _release(name: '4.5.0', versionCodes: [180]),
          ],
        ),
      );

      expect(
        const ReleasePlayDraftStatusService().isDone(
          status: status,
          track: 'internal',
          versionName: '4.5.0',
          versionCode: 180,
          releaseNotesLanguage: 'en-US',
          releaseNotesText: 'Release notes',
        ),
        isFalse,
      );
    });

    test('is pending when release notes differ', () {
      final status = _status(
        track: _track(
          'internal',
          releases: [
            _release(name: '4.5.0', versionCodes: [180]),
          ],
        ),
      );

      expect(
        const ReleasePlayDraftStatusService().isDone(
          status: status,
          track: 'internal',
          versionName: '4.5.0',
          versionCode: 180,
          releaseNotesLanguage: 'en-US',
          releaseNotesText: 'Different release notes',
        ),
        isFalse,
      );
    });
  });
}

PlayReleaseStatus _status({
  PlayTrackStatus? production,
  required PlayTrackStatus track,
}) {
  return PlayReleaseStatus(
    track: 'production',
    production: production ?? _track('production'),
    tracks: [production ?? _track('production'), track],
    defaultLanguage: 'en-US',
    contactEmail: null,
    contactWebsite: null,
    contactPhone: null,
    listingLanguages: const ['en-US'],
  );
}

PlayTrackStatus _track(
  String name, {
  List<PlayTrackRelease> releases = const [],
}) {
  return PlayTrackStatus(name: name, releases: releases);
}

PlayTrackRelease _release({
  required String name,
  required List<int> versionCodes,
  String status = 'draft',
}) {
  return PlayTrackRelease(
    name: name,
    status: status,
    versionCodes: versionCodes,
    releaseNotesCount: 1,
    releaseNotes: const [
      PlayReleaseNoteStatus(language: 'en-US', text: 'Release notes'),
    ],
    userFraction: null,
  );
}
