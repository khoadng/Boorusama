import 'dart:io';

import '../../release_version.dart';
import 'metadata.dart';

final class PlayDraftPlan {
  const PlayDraftPlan({
    required this.packageName,
    required this.track,
    required this.version,
    required this.bundle,
    required this.releaseNotesLanguage,
    required this.metadata,
    required this.productionMaxVersionCode,
    required this.willBuild,
  });

  final String packageName;
  final String track;
  final ReleaseVersion version;
  final File bundle;
  final String releaseNotesLanguage;
  final PlayReleaseMetadata metadata;
  final int? productionMaxVersionCode;
  final bool willBuild;
}
