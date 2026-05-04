import 'dart:io';

import 'build_mode.dart';
import 'build_target.dart';

final class BuildOptions {
  const BuildOptions({
    required this.target,
    required this.buildMode,
    required this.outputDir,
    required this.extraFlutterArgs,
    this.flavor,
    this.foss = false,
    this.verbose = false,
    this.dryRun = false,
    this.ci = false,
    this.noCodesign = false,
    this.failFast = false,
    this.flutterVerbose = false,
  });

  final BuildTarget target;
  final String? flavor;
  final BuildMode buildMode;
  final Directory outputDir;
  final bool foss;
  final bool verbose;
  final bool dryRun;
  final bool ci;
  final bool noCodesign;
  final bool failFast;
  final bool flutterVerbose;
  final List<String> extraFlutterArgs;

  BuildOptions copyWith({Directory? outputDir}) {
    return BuildOptions(
      target: target,
      flavor: flavor,
      buildMode: buildMode,
      outputDir: outputDir ?? this.outputDir,
      foss: foss,
      verbose: verbose,
      dryRun: dryRun,
      ci: ci,
      noCodesign: noCodesign,
      failFast: failFast,
      flutterVerbose: flutterVerbose,
      extraFlutterArgs: extraFlutterArgs,
    );
  }
}
