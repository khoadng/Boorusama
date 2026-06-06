import 'dart:io';

final class ReleaseFlowOptions {
  const ReleaseFlowOptions({
    required this.versionName,
    required this.githubRepo,
    required this.githubWorkflow,
    required this.playDraftTrack,
    required this.outputDir,
    required this.releaseNotesLanguage,
  });

  final String versionName;
  final String? githubRepo;
  final String githubWorkflow;
  final String playDraftTrack;
  final Directory outputDir;
  final String releaseNotesLanguage;
}
