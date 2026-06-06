import 'dart:io';

import '../../io/logger.dart';
import '../../project/env.dart';
import '../../project/project.dart';
import '../../tool/tool_runner.dart';
import '../flow/options.dart';
import '../flow/plan.dart';
import '../flow/steps.dart';
import '../prepare/plan.dart';
import '../version/release_version.dart';
import 'repository.dart';
import 'tag_publish.dart';

abstract interface class ReleaseTagStep {
  Future<bool> isDone(ReleasePreparePlan plan, ReleaseFlowOptions options);

  Future<void> createTag(ReleaseFlowOptions options);

  Future<void> rollbackTag(ReleaseFlowOptions options);
}

final class ReleaseTagFlowStep extends ReleaseFlowPhase {
  const ReleaseTagFlowStep(this.tagStep);

  final ReleaseTagStep tagStep;

  @override
  String get id => ReleaseFlowPhaseIds.tag;

  @override
  String get label => 'Create and push release tag';

  @override
  Future<ReleaseFlowStepStatus> status(ReleaseFlowContext context) async {
    if (context.anyReleaseTagDestinationComplete) {
      return ReleaseFlowStepStatus.complete;
    }
    if (!context.prepareReady) return ReleaseFlowStepStatus.pending;
    return await tagStep.isDone(context.prepare, context.options)
        ? ReleaseFlowStepStatus.done
        : ReleaseFlowStepStatus.pending;
  }

  @override
  Future<void> apply(ReleaseFlowContext context) {
    return tagStep.createTag(context.options);
  }

  @override
  Future<void> rollback(ReleaseFlowContext context) {
    return tagStep.rollbackTag(context.options);
  }
}

final class RealReleaseTagStep implements ReleaseTagStep {
  const RealReleaseTagStep({
    required this.root,
    required this.env,
    required this.tools,
    required this.logger,
  });

  final Directory root;
  final Env env;
  final ToolRunner tools;
  final Logger logger;

  @override
  Future<bool> isDone(
    ReleasePreparePlan plan,
    ReleaseFlowOptions options,
  ) {
    final git = GitRelease(tools);
    return ReleaseTagPublishStatusService(
      git,
    ).isDone(tag: plan.tag, pushTag: true);
  }

  @override
  Future<void> createTag(ReleaseFlowOptions options) async {
    final project = await Project.load(root: root, env: env, tools: tools);
    final version = ReleaseVersion.fromPubspec(project.pubspec);
    final git = GitRelease(tools);

    logger.info('Preparing release tag ${version.tag}');
    logger.debug('Version: ${version.full}');

    await git.requireCleanTree(allowDirty: false);
    await git.requireMissingTag(version.tag);

    var localTagCreated = false;
    try {
      await git.createTag(version.tag, 'Release ${version.name}');
      localTagCreated = true;
      await git.pushTag(version.tag);
    } on Object {
      if (localTagCreated) {
        logger.warning(
          'Deleting local tag ${version.tag} because pushing it failed.',
        );
        await git.deleteLocalTag(version.tag);
      }
      rethrow;
    }

    logger.info('Release tag ${version.tag} completed.');
  }

  @override
  Future<void> rollbackTag(ReleaseFlowOptions options) {
    // Once this phase completes, the tag may have been pushed. Do not delete it
    // automatically.
    return Future.value();
  }
}
