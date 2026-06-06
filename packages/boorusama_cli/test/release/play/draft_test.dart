import 'dart:io';

import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/release/play/draft/core.dart';
import 'package:boorusama_cli/src/release/play/draft/metadata.dart';
import 'package:boorusama_cli/src/release/play/repository.dart';
import 'package:boorusama_cli/src/release/play/status.dart';
import 'package:test/test.dart';

void main() {
  test('creates draft release payload through repository', () async {
    final temp = await Directory.systemTemp.createTemp('play_draft_test_');
    addTearDown(() => temp.delete(recursive: true));
    final bundle = File('${temp.path}/app-release.aab');
    bundle.writeAsStringSync('bundle');
    final repository = _FakePlayReleaseRepository(versionCode: 179);

    final result = await PlayDraftReleaseService(repository: repository)
        .createDraft(
          bundle: bundle,
          metadata: const PlayReleaseMetadataBuilder().build(
            name: '4.5.0',
            changelogSection: '  Release notes  ',
            language: 'en-US',
          ),
        );

    expect(result.track, 'production');
    expect(result.versionName, '4.5.0');
    expect(result.versionCode, 179);
    expect(repository.createdReleases, hasLength(1));

    final release = repository.createdReleases.single;
    expect(release.bundle.path, bundle.path);
    expect(release.track, 'production');
    expect(release.name, '4.5.0');
    expect(release.releaseNotes, hasLength(1));
    expect(release.releaseNotes.single.language, 'en-US');
    expect(release.releaseNotes.single.text, 'Release notes');
  });

  test('rejects missing bundle before repository call', () {
    final repository = _FakePlayReleaseRepository(versionCode: 179);

    expect(
      () => PlayDraftReleaseService(repository: repository).createDraft(
        bundle: File('/does/not/exist.aab'),
        metadata: const PlayReleaseMetadataBuilder().build(
          name: '4.5.0',
          changelogSection: 'Release notes',
          language: 'en-US',
        ),
      ),
      throwsA(isA<ProcessFailure>()),
    );
    expect(repository.createdReleases, isEmpty);
  });
}

final class _FakePlayReleaseRepository implements PlayReleaseRepository {
  _FakePlayReleaseRepository({required this.versionCode});

  final int versionCode;
  final createdReleases = <PlayDraftRelease>[];

  @override
  Future<int> createDraftRelease(PlayDraftRelease release) async {
    createdReleases.add(release);
    return versionCode;
  }

  @override
  Future<PlayReleaseStatus> fetchStatus() {
    throw UnimplementedError();
  }
}
