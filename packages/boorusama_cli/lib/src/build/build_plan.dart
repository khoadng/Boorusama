import 'dart:io';

import '../io/platform.dart';
import 'build_mode.dart';
import 'build_target.dart';

final class BuildPlan {
  const BuildPlan({
    required this.target,
    required this.buildMode,
    required this.flutterArgs,
    required this.outputDir,
    required this.artifactName,
    required this.targetFile,
    this.flavor,
    this.requiredHost,
  });

  final BuildTarget target;
  final String? flavor;
  final BuildMode buildMode;
  final List<String> flutterArgs;
  final Directory outputDir;
  final String artifactName;
  final String targetFile;
  final HostPlatform? requiredHost;
}
