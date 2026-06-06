import 'dart:io';

import '../../../builds/build_mode.dart';
import '../../../builds/build_options.dart';
import '../../../builds/build_runner.dart';
import '../../../builds/build_target.dart';
import '../../../builds/release_channel.dart';
import '../../../io/logger.dart';
import '../../../io/process_runner.dart';
import '../../../project/project.dart';
import '../../../tool/tool_runner.dart';
import '../../changelog.dart';
import '../../git/repository.dart';
import '../../version/release_version.dart';
import '../client.dart';
import '../config.dart';
import 'core.dart';
import 'metadata.dart';
import 'plan.dart';

final class PlayDraftService {
  const PlayDraftService({
    required this.root,
    required this.project,
    required this.tools,
    required this.logger,
    this.onProgress,
  });

  final Directory root;
  final Project project;
  final ToolRunner tools;
  final Logger logger;
  final void Function(String message)? onProgress;

  Future<PlayDraftPlan> plan({
    required String track,
    required String? bundlePath,
    required Directory outputDir,
    required String releaseNotesLanguage,
    required bool allowDirty,
  }) async {
    final version = ReleaseVersion.fromPubspec(project.pubspec);
    final releaseNotes = Changelog(
      File('${root.path}/CHANGELOG.md'),
    ).sectionFor(version.name);
    final metadata = const PlayReleaseMetadataBuilder().build(
      name: version.name,
      changelogSection: releaseNotes,
      language: releaseNotesLanguage,
    );
    final playConfig = PlayReleaseConfigResolver(
      root: root,
      project: project,
    ).resolve();
    final productionRepository = GooglePlayReleaseRepository(
      serviceAccountJsonFile: playConfig.serviceAccountJsonFile,
      packageName: playConfig.packageName,
      onProgress: onProgress,
    );

    onProgress?.call('Checking Google Play release state.');
    final playStatus = await productionRepository.fetchStatus();
    final playMaxVersionCode = playStatus.maxVersionCode;
    final playMaxVersionCodeTrack = playStatus.maxVersionCodeTrack?.name;
    final versionCode = int.tryParse(version.buildNumber ?? '');
    if (versionCode == null) {
      throw ProcessFailure(
        'Current pubspec version does not have a numeric build number: ${version.full}.',
      );
    }
    if (playMaxVersionCode != null && versionCode <= playMaxVersionCode) {
      throw ProcessFailure(
        'Current versionCode $versionCode is not newer than Google Play max $playMaxVersionCode. Run release prepare <next-version> --apply first.',
      );
    }

    await GitRelease(tools).requireCleanTree(allowDirty: allowDirty);

    return PlayDraftPlan(
      packageName: playConfig.packageName,
      track: track,
      version: version,
      bundle: bundlePath == null
          ? File('${outputDir.path}/app-prod-release.aab')
          : File(bundlePath),
      releaseNotesLanguage: releaseNotesLanguage,
      metadata: metadata,
      playMaxVersionCode: playMaxVersionCode,
      playMaxVersionCodeTrack: playMaxVersionCodeTrack,
      willBuild: bundlePath == null,
    );
  }

  Future<PlayDraftReleaseResult> apply(PlayDraftPlan plan) async {
    final playConfig = PlayReleaseConfigResolver(
      root: root,
      project: project,
    ).resolve();
    final artifact = plan.willBuild
        ? await BuildRunner(tools: tools, logger: logger).run(
            BuildOptions(
              target: BuildTarget.aab,
              flavor: 'prod',
              buildMode: BuildMode.release,
              outputDir: plan.bundle.parent,
              ci: logger.ci,
              verbose: logger.verbose,
              releaseChannel: BuildReleaseChannel.play,
              extraFlutterArgs: const [],
            ),
          )
        : null;
    final bundle = artifact?.file ?? plan.bundle;

    return PlayDraftReleaseService(
      repository: GooglePlayReleaseRepository(
        serviceAccountJsonFile: playConfig.serviceAccountJsonFile,
        packageName: playConfig.packageName,
        track: plan.track,
        onProgress: onProgress,
      ),
      track: plan.track,
    ).createDraft(bundle: bundle, metadata: plan.metadata);
  }
}
