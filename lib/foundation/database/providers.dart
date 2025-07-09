// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

// Project imports:
import '../info/app_info.dart';

const _kFolderName = 'data';

final databaseFolderPathProvider = FutureProvider<String>((ref) async {
  final applicationDocumentsDir = await getApplicationDocumentsDirectory();
  final appName = ref.watch(appInfoProvider).appName;

  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => join(applicationDocumentsDir.path, _kFolderName),
    TargetPlatform.windows => join(
      applicationDocumentsDir.path,
      appName,
      _kFolderName,
    ),
    TargetPlatform.linux || TargetPlatform.fuchsia => join(
      applicationDocumentsDir.path,
      appName.toLowerCase().replaceAll(' ', '_'),
      _kFolderName,
    ),
  };
});
