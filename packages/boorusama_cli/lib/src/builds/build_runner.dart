import 'dart:io';

import '../io/archive.dart';
import '../io/linux_architecture.dart';
import '../io/logger.dart';
import '../io/platform.dart';
import '../io/process_runner.dart';
import '../package/android.dart';
import '../package/appimage.dart';
import '../package/apple.dart';
import '../package/artifact.dart';
import '../package/linux.dart';
import '../package/packager.dart';
import '../package/web.dart';
import '../package/windows.dart';
import '../project/config.dart';
import '../project/project.dart';
import '../tool/tool_runner.dart';
import 'build_options.dart';
import 'build_requirements.dart';
import 'build_plan.dart';
import 'build_target.dart';
import 'release_channel.dart';
import 'output_dir.dart';
import 'codegen.dart';
import 'dart_defines.dart';
import 'flutter.dart';
import 'foss.dart';

final class BuildRunner {
  const BuildRunner({required this.tools, required this.logger});

  final ToolRunner tools;
  final Logger logger;

  Future<Artifact> run(BuildOptions options) async {
    final startedAt = DateTime.now();
    final outputDir = OutputDir.resolve(tools.root, options.outputDir);
    OutputDir.validateWritable(outputDir);
    final resolvedOptions = options.copyWith(outputDir: outputDir);

    final project = await Project.load(
      root: tools.root,
      env: Project.loadEnv(tools.root),
      tools: tools,
    );
    final plan = await _createPlan(project, resolvedOptions);

    logger.info(
      'Building ${project.pubspec.name} version ${project.pubspec.version} as ${resolvedOptions.target.name} (${resolvedOptions.buildMode.name})',
    );
    logger.debug('Target file: ${plan.targetFile}');
    logger.debug('Flavor: ${resolvedOptions.flavor ?? 'none'}');
    logger.debug('FOSS build: ${resolvedOptions.foss}');

    FossBuild.warnAboutLeftoverBackups(project, logger);

    await _validatePlan(plan);
    final foss = FossBuild(tools: tools, logger: logger);
    final artifact = await foss.guard(
      enabled: resolvedOptions.foss,
      project: project,
      body: (buildProject, buildTools) async {
        await Codegen(
          tools: buildTools,
          logger: logger,
        ).run(buildProject);
        await Flutter(buildTools).build(buildProject, plan);
        if (resolvedOptions.dryRun) {
          final file = File('${plan.outputDir.path}/${plan.artifactName}');
          return Artifact(type: _artifactType(plan), file: file);
        }
        return _packager(plan).package(buildProject, plan);
      },
    );

    _printSummary(
      project,
      plan,
      options,
      artifact,
      DateTime.now().difference(startedAt),
    );
    return artifact;
  }

  Future<BuildPlan> _createPlan(Project project, BuildOptions options) async {
    final flutterArgs = <String>[];

    if (options.flavor != null && options.target.requiresFlavor) {
      flutterArgs.addAll(['--flavor', options.flavor!]);
    }

    flutterArgs.add(options.buildMode.flag);
    if (options.noCodesign) flutterArgs.add('--no-codesign');
    if (options.flutterVerbose) flutterArgs.add('--verbose');

    if (options.flavor != null) {
      flutterArgs.addAll([
        '--dart-define-from-file',
        BoorusamaConfig.flavors[options.flavor]!.envFile,
      ]);
    }

    final targetFile = options.foss
        ? BoorusamaConfig.fossTargetFile
        : BoorusamaConfig.defaultTargetFile;

    final defines = {
      ...DartDefines.common(
        gitCommit: project.git.commit,
        gitBranch: project.git.branch,
        foss: options.foss,
        releaseChannel: options.releaseChannel.wireName,
        timestamp: DateTime.now(),
      ),
      ...DartDefines.androidFoss(options),
    };

    for (final requirement in BuildRequirements.requiredEnv(
      target: options.target,
      flavor: options.flavor,
      foss: options.foss,
    )) {
      final key = project.env[requirement.key];
      if (key == null || key.isEmpty) {
        throw ProcessFailure(
          '${requirement.key} is required for prod ${options.target.name} builds. Set it in .env',
        );
      }
      defines[requirement.key] = key;
    }

    flutterArgs
      ..addAll(DartDefines.args(defines))
      ..addAll(['-t', targetFile])
      ..addAll(options.extraFlutterArgs);

    return BuildPlan(
      target: options.target,
      flavor: options.flavor,
      buildMode: options.buildMode,
      flutterArgs: flutterArgs,
      outputDir: options.outputDir,
      artifactName: _artifactName(project, options),
      targetFile: targetFile,
      requiredHost: BuildRequirements.requiredHost(options.target),
    );
  }

  Future<void> _validatePlan(BuildPlan plan) async {
    if (plan.requiredHost != null &&
        currentHostPlatform() != plan.requiredHost) {
      throw ProcessFailure(
        '${plan.target.name} builds require ${plan.requiredHost!.label}. Current host is ${currentHostPlatform().label}.',
      );
    }

    for (final tool in BuildRequirements.requiredTools(
      plan.target,
      tools.toolchain,
    )) {
      if (!await tools.exists(tool)) {
        final hint = tool == tools.toolchain.createDmg
            ? ' Install with: brew install create-dmg'
            : tool == tools.toolchain.pod
            ? ' Install with: brew install cocoapods'
            : tool == tools.toolchain.appImageTool
            ? ' Install appimagetool or let appimage builds download it.'
            : '';
        throw ProcessFailure('${tool.displayName} not found.$hint');
      }
    }
  }

  Packager _packager(BuildPlan plan) {
    final archive = Archive(tools);
    return switch (plan.target) {
      BuildTarget.apk || BuildTarget.aab => const AndroidPackager(),
      BuildTarget.ipa || BuildTarget.dmg => ApplePackager(tools),
      BuildTarget.windows => WindowsPackager(archive),
      BuildTarget.linux => LinuxPackager(archive),
      BuildTarget.appimage => AppImagePackager(tools),
      BuildTarget.web => WebPackager(archive),
    };
  }

  String _artifactType(BuildPlan plan) => switch (plan.target) {
    BuildTarget.apk => 'APK',
    BuildTarget.aab => 'AAB',
    BuildTarget.ipa => 'IPA',
    BuildTarget.dmg => 'DMG',
    BuildTarget.windows => 'Windows ZIP',
    BuildTarget.linux => 'Linux TAR.GZ',
    BuildTarget.appimage => 'AppImage',
    BuildTarget.web => 'Web ZIP',
  };

  String _artifactName(Project project, BuildOptions options) {
    final app = project.pubspec.name;
    final version = project.pubspec.version;
    final flavor = options.flavor;

    return switch (options.target) {
      BuildTarget.apk =>
        options.foss
            ? '$app-$version-${flavor ?? 'universal'}-foss.apk'
            : '$app-$version-${flavor ?? 'universal'}.apk',
      BuildTarget.aab =>
        flavor == 'dev' ? '$app-$version-dev.aab' : '$app-$version.aab',
      BuildTarget.ipa =>
        flavor == 'dev' ? '${app}_$version-dev.ipa' : '${app}_$version.ipa',
      BuildTarget.dmg =>
        flavor == 'dev' ? '$app-$version-dev.dmg' : '$app-$version.dmg',
      BuildTarget.windows =>
        options.foss ? '$app-$version-foss.zip' : '$app-$version.zip',
      BuildTarget.linux =>
        options.foss
            ? '$app-$version-foss-linux-${_linuxArtifactArchitecture()}.tar.gz'
            : '$app-$version-linux-${_linuxArtifactArchitecture()}.tar.gz',
      BuildTarget.appimage =>
        options.foss
            ? '$app-$version-foss-linux-${_linuxArtifactArchitecture()}.AppImage'
            : '$app-$version-linux-${_linuxArtifactArchitecture()}.AppImage',
      BuildTarget.web =>
        options.foss ? '$app-$version-foss-web.zip' : '$app-$version-web.zip',
    };
  }

  String _linuxArtifactArchitecture() => currentLinuxArchitecture() ?? 'x64';

  void _printSummary(
    Project project,
    BuildPlan plan,
    BuildOptions options,
    Artifact artifact,
    Duration duration,
  ) {
    print('');
    logger.info('=== BUILD SUMMARY ===');
    print('App: ${project.pubspec.name} v${project.pubspec.version}');
    print('Format: ${options.target.name} (${options.buildMode.name})');
    print('Flavor: ${options.flavor ?? 'none'}');
    print('FOSS: ${options.foss}');
    print('Duration: ${_formatDuration(duration)}');
    print('');
    print('Artifacts:');
    print('  ${artifact.type}: ${artifact.file.path}');
    print('');
    logger.info('Build completed successfully!');
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${duration.inSeconds}s';
  }
}
