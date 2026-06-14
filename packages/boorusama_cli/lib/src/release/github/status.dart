import 'dart:convert';

import '../../io/process_runner.dart';
import '../flow/plan.dart';

abstract interface class ReleaseGithubStatusRepository {
  Future<bool> ghInstalled();

  Future<String?> releaseView({
    required String repo,
    required String tag,
  });

  Future<String?> workflowRuns({
    required String repo,
    required String workflow,
    required String tag,
  });

  Future<String?> tagCommit(String tag);
}

final class ReleaseGithubStatusService {
  const ReleaseGithubStatusService(this.repository);

  final ReleaseGithubStatusRepository repository;

  Future<bool> isDone({
    required String repo,
    required String tag,
    required String workflow,
  }) async {
    final status = await this.status(repo: repo, tag: tag, workflow: workflow);
    return status == ReleaseFlowStepStatus.waitingManualPublish ||
        status == ReleaseFlowStepStatus.complete ||
        status == ReleaseFlowStepStatus.done;
  }

  Future<ReleaseFlowStepStatus> status({
    required String repo,
    required String tag,
    required String workflow,
  }) async {
    if (!await repository.ghInstalled()) return ReleaseFlowStepStatus.pending;
    final output = await repository.releaseView(repo: repo, tag: tag);
    final release = _release(output);
    if (release != null) {
      return release.isDraft
          ? ReleaseFlowStepStatus.waitingManualPublish
          : ReleaseFlowStepStatus.complete;
    }

    final currentTagCommit = await repository.tagCommit(tag);
    if (currentTagCommit == null || currentTagCommit.isEmpty) {
      return ReleaseFlowStepStatus.pending;
    }

    final workflowOutput = await repository.workflowRuns(
      repo: repo,
      workflow: workflow,
      tag: tag,
    );
    final run = _latestRun(workflowOutput, currentTagCommit: currentTagCommit);
    if (run == null) return ReleaseFlowStepStatus.pending;

    if (run.status == 'completed' && run.conclusion == 'success') {
      return ReleaseFlowStepStatus.waitingManualPublish;
    }
    if (run.status == 'completed') {
      throw ProcessFailure(
        'GitHub release workflow ${run.conclusion ?? 'completed unsuccessfully'} for $tag. ${run.url ?? ''}'
            .trim(),
      );
    }
    return ReleaseFlowStepStatus.pending;
  }

  _GithubRelease? _release(String? output) {
    if (output == null || output.isEmpty) return null;
    final decoded = jsonDecode(output);
    if (decoded is! Map) return null;
    final tagName = decoded['tagName'];
    if (tagName is! String || tagName.isEmpty) return null;
    return _GithubRelease(
      tagName: tagName,
      isDraft: decoded['isDraft'] == true,
    );
  }

  _GithubWorkflowRun? _latestRun(
    String? output, {
    required String currentTagCommit,
  }) {
    if (output == null || output.isEmpty) return null;
    final decoded = jsonDecode(output);
    final runs = decoded is List
        ? decoded
        : decoded is Map && decoded['workflow_runs'] is List
        ? decoded['workflow_runs'] as List
        : const <Object?>[];
    for (final run in runs) {
      if (run is! Map) continue;
      if (run['headSha'] != currentTagCommit) continue;
      return _GithubWorkflowRun(
        status: run['status'] as String?,
        conclusion: run['conclusion'] as String?,
        url: run['url'] as String?,
      );
    }

    return null;
  }
}

final class _GithubRelease {
  const _GithubRelease({required this.tagName, required this.isDraft});

  final String tagName;
  final bool isDraft;
}

final class _GithubWorkflowRun {
  const _GithubWorkflowRun({
    required this.status,
    required this.conclusion,
    required this.url,
  });

  final String? status;
  final String? conclusion;
  final String? url;
}
