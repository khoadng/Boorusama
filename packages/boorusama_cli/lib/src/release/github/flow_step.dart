import 'dart:io';

import '../../io/logger.dart';
import '../../io/process_runner.dart';
import '../../tool/tool_runner.dart';
import '../flow/options.dart';
import '../flow/plan.dart';
import '../flow/steps.dart';
import '../git/repository.dart';
import 'status.dart';

abstract interface class ReleaseGithubStep {
  Future<ReleaseFlowStepStatus> status({
    required String repo,
    required String tag,
    required ReleaseFlowOptions options,
  });

  Future<bool> isDone({
    required String repo,
    required String tag,
    required ReleaseFlowOptions options,
  });

  Future<void> trigger({
    required String repo,
    required String tag,
    required ReleaseFlowOptions options,
  });

  Future<void> rollbackTrigger({
    required String repo,
    required String tag,
    required ReleaseFlowOptions options,
  });
}

final class GithubReleaseDestination extends ReleaseDestination {
  const GithubReleaseDestination(this.github);

  final ReleaseGithubStep github;

  @override
  String get id => 'github';

  @override
  String get label => 'GitHub';

  @override
  bool get shouldPlanEarly => true;

  @override
  bool get contributesPublicCompletion => true;

  @override
  bool get requiresReleaseTag => true;

  @override
  Future<ReleaseFlowStepStatus> status(ReleaseFlowContext context) {
    final repo = context.githubRepo;
    if (repo == null || repo.isEmpty) {
      throw const ProcessFailure(
        'GitHub repository is required before checking release workflow state.',
      );
    }
    return github.status(
      repo: repo,
      tag: context.prepare.tag,
      options: context.options,
    );
  }

  @override
  Future<void> apply(ReleaseFlowContext context) {
    final repo = context.githubRepo;
    if (repo == null || repo.isEmpty) {
      throw const ProcessFailure(
        'GitHub repository is required before triggering the release workflow.',
      );
    }
    return github.trigger(
      repo: repo,
      tag: context.prepare.tag,
      options: context.options,
    );
  }

  @override
  Future<void> rollback(ReleaseFlowContext context) {
    final repo = context.githubRepo;
    if (repo == null || repo.isEmpty) return Future.value();
    return github.rollbackTrigger(
      repo: repo,
      tag: context.prepare.tag,
      options: context.options,
    );
  }

  @override
  String waitingManualPublishMessage(ReleaseFlowContext context) {
    return 'Publish GitHub draft release ${context.prepare.tag}.';
  }

  @override
  String completeMessage(ReleaseFlowContext context) {
    return 'GitHub release ${context.prepare.tag} is published.';
  }
}

final class RealReleaseGithubStep
    implements ReleaseGithubStep, ReleaseGithubStatusRepository {
  const RealReleaseGithubStep({
    required this.root,
    required this.tools,
    required this.processRunner,
    required this.logger,
  });

  final Directory root;
  final ToolRunner tools;
  final ProcessRunner processRunner;
  final Logger logger;

  @override
  Future<ReleaseFlowStepStatus> status({
    required String repo,
    required String tag,
    required ReleaseFlowOptions options,
  }) {
    return ReleaseGithubStatusService(this).status(
      repo: repo,
      tag: tag,
      workflow: options.githubWorkflow,
    );
  }

  @override
  Future<bool> isDone({
    required String repo,
    required String tag,
    required ReleaseFlowOptions options,
  }) async {
    return await status(repo: repo, tag: tag, options: options) !=
        ReleaseFlowStepStatus.pending;
  }

  @override
  Future<bool> ghInstalled() => processRunner.exists('gh');

  @override
  Future<String?> releaseView({
    required String repo,
    required String tag,
  }) async {
    final output = await processRunner.output(
      'gh',
      ['release', 'view', tag, '--repo', repo, '--json', 'tagName,isDraft'],
      workingDirectory: root,
    );
    if (output == 'unknown' || output.isEmpty) return null;
    return output;
  }

  @override
  Future<String?> workflowRuns({
    required String repo,
    required String workflow,
    required String tag,
  }) async {
    final output = await processRunner.output(
      'gh',
      [
        'run',
        'list',
        '--repo',
        repo,
        '--workflow',
        workflow,
        '--branch',
        tag,
        '--json',
        'status,conclusion,url,headSha',
        '--limit',
        '10',
      ],
      workingDirectory: root,
    );
    if (output == 'unknown' || output.isEmpty) return null;
    return output;
  }

  @override
  Future<String?> tagCommit(String tag) async {
    final output = await tools.gitOutput(['rev-list', '-n', '1', tag]);
    if (output == 'unknown' || output.trim().isEmpty) return null;
    return output.trim();
  }

  @override
  Future<void> trigger({
    required String repo,
    required String tag,
    required ReleaseFlowOptions options,
  }) async {
    final git = GitRelease(tools);
    await git.requireLocalHeadMatchesTag(tag);
    await git.requireRemoteTag(tag);

    if (!await processRunner.exists('gh')) {
      throw const ProcessFailure(
        'GitHub CLI not found. Install gh and authenticate before running the GitHub release workflow.',
      );
    }

    logger.info(
      'Triggering GitHub release workflow ${options.githubWorkflow}.',
    );
    await processRunner.run(
      'gh',
      [
        'workflow',
        'run',
        options.githubWorkflow,
        '--repo',
        repo,
        '--ref',
        tag,
        '-f',
        'release_tag=$tag',
        '-f',
        'prerelease=false',
        '-f',
        'recreate_release=false',
      ],
      workingDirectory: root,
    );
  }

  @override
  Future<void> rollbackTrigger({
    required String repo,
    required String tag,
    required ReleaseFlowOptions options,
  }) {
    // A dispatched GitHub workflow may already be running; do not cancel it
    // automatically.
    return Future.value();
  }
}
