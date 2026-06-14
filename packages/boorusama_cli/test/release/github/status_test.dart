import 'package:boorusama_cli/src/io/process_runner.dart';
import 'package:boorusama_cli/src/release/flow/plan.dart';
import 'package:boorusama_cli/src/release/github/status.dart';
import 'package:test/test.dart';

void main() {
  group('ReleaseGithubStatusService', () {
    test('is pending when GitHub CLI is unavailable', () async {
      final repository = _FakeGithubStatusRepository(installed: false);
      final service = ReleaseGithubStatusService(repository);

      expect(
        await service.isDone(
          repo: 'owner/repo',
          tag: 'v1.2.3',
          workflow: 'github-release.yml',
        ),
        isFalse,
      );
      expect(repository.releaseViewCalls, isZero);
    });

    test('is pending when release lookup is missing', () async {
      final repository = _FakeGithubStatusRepository();
      final service = ReleaseGithubStatusService(repository);

      expect(
        await service.isDone(
          repo: 'owner/repo',
          tag: 'v1.2.3',
          workflow: 'github-release.yml',
        ),
        isFalse,
      );
    });

    test(
      'is complete when release lookup returns a published release',
      () async {
        final repository = _FakeGithubStatusRepository(
          releaseViewOutput: '{"tagName":"v1.2.3","isDraft":false}',
        );
        final service = ReleaseGithubStatusService(repository);

        expect(
          await service.status(
            repo: 'owner/repo',
            tag: 'v1.2.3',
            workflow: 'github-release.yml',
          ),
          ReleaseFlowStepStatus.complete,
        );
      },
    );

    test('is waiting when release lookup returns a draft release', () async {
      final repository = _FakeGithubStatusRepository(
        releaseViewOutput: '{"tagName":"v1.2.3","isDraft":true}',
      );
      final service = ReleaseGithubStatusService(repository);

      expect(
        await service.status(
          repo: 'owner/repo',
          tag: 'v1.2.3',
          workflow: 'github-release.yml',
        ),
        ReleaseFlowStepStatus.waitingManualPublish,
      );
      expect(
        await service.isDone(
          repo: 'owner/repo',
          tag: 'v1.2.3',
          workflow: 'github-release.yml',
        ),
        isTrue,
      );
    });

    test('is waiting when workflow run completed successfully', () async {
      final repository = _FakeGithubStatusRepository(
        tagCommitOutput: 'abc123',
        workflowRunsOutput:
            '[{"headSha":"abc123","status":"completed","conclusion":"success","url":"https://example.com/run"}]',
      );
      final service = ReleaseGithubStatusService(repository);

      expect(
        await service.status(
          repo: 'owner/repo',
          tag: 'v1.2.3',
          workflow: 'github-release.yml',
        ),
        ReleaseFlowStepStatus.waitingManualPublish,
      );
    });

    test('is pending when workflow run is still running', () async {
      final repository = _FakeGithubStatusRepository(
        tagCommitOutput: 'abc123',
        workflowRunsOutput:
            '[{"headSha":"abc123","status":"in_progress","conclusion":null,"url":"https://example.com/run"}]',
      );
      final service = ReleaseGithubStatusService(repository);

      expect(
        await service.isDone(
          repo: 'owner/repo',
          tag: 'v1.2.3',
          workflow: 'github-release.yml',
        ),
        isFalse,
      );
    });

    test('blocks when workflow run failed', () {
      final repository = _FakeGithubStatusRepository(
        tagCommitOutput: 'abc123',
        workflowRunsOutput:
            '[{"headSha":"abc123","status":"completed","conclusion":"failure","url":"https://example.com/run"}]',
      );
      final service = ReleaseGithubStatusService(repository);

      expect(
        () => service.isDone(
          repo: 'owner/repo',
          tag: 'v1.2.3',
          workflow: 'github-release.yml',
        ),
        throwsA(isA<ProcessFailure>()),
      );
    });

    test('ignores stale workflow runs when current tag does not exist', () async {
      final repository = _FakeGithubStatusRepository(
        workflowRunsOutput:
            '[{"headSha":"old123","status":"completed","conclusion":"startup_failure","url":"https://example.com/run"}]',
      );
      final service = ReleaseGithubStatusService(repository);

      expect(
        await service.status(
          repo: 'owner/repo',
          tag: 'v1.2.3',
          workflow: 'github-release.yml',
        ),
        ReleaseFlowStepStatus.pending,
      );
      expect(repository.workflowRunsCalls, isZero);
    });

    test('ignores stale workflow runs for a previous tag commit', () async {
      final repository = _FakeGithubStatusRepository(
        tagCommitOutput: 'new123',
        workflowRunsOutput:
            '[{"headSha":"old123","status":"completed","conclusion":"startup_failure","url":"https://example.com/run"}]',
      );
      final service = ReleaseGithubStatusService(repository);

      expect(
        await service.status(
          repo: 'owner/repo',
          tag: 'v1.2.3',
          workflow: 'github-release.yml',
        ),
        ReleaseFlowStepStatus.pending,
      );
    });

    test('uses matching workflow run when stale run is listed first', () async {
      final repository = _FakeGithubStatusRepository(
        tagCommitOutput: 'new123',
        workflowRunsOutput:
            '[{"headSha":"old123","status":"completed","conclusion":"failure","url":"https://example.com/old"},{"headSha":"new123","status":"completed","conclusion":"success","url":"https://example.com/new"}]',
      );
      final service = ReleaseGithubStatusService(repository);

      expect(
        await service.status(
          repo: 'owner/repo',
          tag: 'v1.2.3',
          workflow: 'github-release.yml',
        ),
        ReleaseFlowStepStatus.waitingManualPublish,
      );
    });
  });
}

final class _FakeGithubStatusRepository
    implements ReleaseGithubStatusRepository {
  _FakeGithubStatusRepository({
    this.installed = true,
    this.releaseViewOutput,
    this.workflowRunsOutput,
    this.tagCommitOutput,
  });

  final bool installed;
  final String? releaseViewOutput;
  final String? workflowRunsOutput;
  final String? tagCommitOutput;
  var releaseViewCalls = 0;
  var workflowRunsCalls = 0;
  var tagCommitCalls = 0;

  @override
  Future<bool> ghInstalled() async => installed;

  @override
  Future<String?> releaseView({
    required String repo,
    required String tag,
  }) async {
    releaseViewCalls++;
    return releaseViewOutput;
  }

  @override
  Future<String?> workflowRuns({
    required String repo,
    required String workflow,
    required String tag,
  }) async {
    workflowRunsCalls++;
    return workflowRunsOutput;
  }

  @override
  Future<String?> tagCommit(String tag) async {
    tagCommitCalls++;
    return tagCommitOutput;
  }
}
