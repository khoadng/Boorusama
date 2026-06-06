import 'dart:io';

import '../../io/logger.dart';
import '../../project/env.dart';
import '../../project/project.dart';
import '../../tool/tool_runner.dart';
import '../changelog.dart';
import '../flow/options.dart';
import '../flow/plan.dart';
import '../flow/steps.dart';
import '../version/release_version.dart';
import 'client.dart';
import 'config.dart';
import 'draft/metadata.dart';
import 'draft/service.dart';
import 'draft_status.dart';

abstract interface class ReleasePlayDraftStep {
  Future<ReleaseFlowStepStatus> status(ReleaseFlowOptions options);

  Future<bool> isDone(ReleaseFlowOptions options);

  Future<void> createDraft(ReleaseFlowOptions options);

  Future<void> rollbackDraft(ReleaseFlowOptions options);
}

final class PlayReleaseDestination extends ReleaseDestination {
  const PlayReleaseDestination(this.playDraft);

  final ReleasePlayDraftStep playDraft;

  @override
  String get id => 'play';

  @override
  String get label => 'Google Play';

  @override
  bool get shouldPlanEarly => true;

  @override
  bool get contributesPublicCompletion => true;

  @override
  Future<ReleaseFlowStepStatus> status(ReleaseFlowContext context) {
    if (context.prepare.googlePlay.api.productionLatestVersionName ==
        context.prepare.versionName) {
      return Future.value(ReleaseFlowStepStatus.complete);
    }
    if (!context.prepareReady) {
      return Future.value(ReleaseFlowStepStatus.pending);
    }
    return playDraft.status(context.options);
  }

  @override
  Future<void> apply(ReleaseFlowContext context) {
    return playDraft.createDraft(context.options);
  }

  @override
  Future<void> rollback(ReleaseFlowContext context) {
    return playDraft.rollbackDraft(context.options);
  }

  @override
  String waitingManualPublishMessage(ReleaseFlowContext context) {
    return 'Publish Google Play production release for ${context.prepare.versionName}.';
  }

  @override
  String completeMessage(ReleaseFlowContext context) {
    return 'Google Play production has ${context.prepare.versionName}.';
  }
}

final class RealReleasePlayDraftStep implements ReleasePlayDraftStep {
  const RealReleasePlayDraftStep({
    required this.root,
    required this.env,
    required this.tools,
    required this.logger,
    this.onProgress,
  });

  final Directory root;
  final Env env;
  final ToolRunner tools;
  final Logger logger;
  final void Function(String message)? onProgress;

  @override
  Future<ReleaseFlowStepStatus> status(ReleaseFlowOptions options) async {
    final project = await Project.load(root: root, env: env, tools: tools);
    final version = ReleaseVersion.fromPubspec(project.pubspec);
    final versionCode = int.tryParse(version.buildNumber ?? '');
    if (versionCode == null) return ReleaseFlowStepStatus.pending;
    final releaseNotes = Changelog(
      File('${root.path}/CHANGELOG.md'),
    ).sectionFor(version.name);
    final metadata = const PlayReleaseMetadataBuilder().build(
      name: version.name,
      changelogSection: releaseNotes,
      language: options.releaseNotesLanguage,
    );

    final playConfig = PlayReleaseConfigResolver(
      root: root,
      project: project,
    ).resolve();
    final status = await GooglePlayReleaseRepository(
      serviceAccountJsonFile: playConfig.serviceAccountJsonFile,
      packageName: playConfig.packageName,
      onProgress: onProgress,
    ).fetchStatus();
    return const ReleasePlayDraftStatusService().status(
      status: status,
      track: options.playDraftTrack,
      versionName: version.name,
      versionCode: versionCode,
      releaseNotesLanguage: metadata.notes.language,
      releaseNotesText: metadata.notes.text,
    );
  }

  @override
  Future<bool> isDone(ReleaseFlowOptions options) async {
    return await status(options) != ReleaseFlowStepStatus.pending;
  }

  @override
  Future<void> createDraft(ReleaseFlowOptions options) async {
    final project = await Project.load(root: root, env: env, tools: tools);
    final service = PlayDraftService(
      root: root,
      project: project,
      tools: tools,
      logger: logger,
      onProgress: onProgress,
    );
    final plan = await service.plan(
      track: options.playDraftTrack,
      bundlePath: null,
      outputDir: options.outputDir,
      releaseNotesLanguage: options.releaseNotesLanguage,
      allowDirty: false,
    );
    await service.apply(plan);
  }

  @override
  Future<void> rollbackDraft(ReleaseFlowOptions options) {
    // A committed Google Play draft cannot be safely un-consumed.
    return Future.value();
  }
}
