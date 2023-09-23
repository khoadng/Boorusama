// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/foundation/permissions.dart';
import 'package:boorusama/foundation/platform.dart';

Future<void> _download(
  BuildContext context,
  WidgetRef ref,
  Post downloadable, {
  PermissionStatus? permission,
  required Settings settings,
}) async {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final service = ref.read(downloadServiceProvider);
  final fileNameGenerator =
      ref.read(downloadFileNameGeneratorProvider(booruConfig));
  final downloadUrl = ref.read(downloadUrlProvider(downloadable));
  final logger = ref.read(loggerProvider);

  Future<void> download() async => service
      .downloadWithSettings(
        settings,
        url: downloadUrl,
        fileNameBuilder: () => fileNameGenerator.generateFor(
          downloadable,
          downloadUrl,
        ),
      )
      .run();

  // Platform doesn't require permissions, just download it right away
  if (permission == null) {
    download();
  }

  if (permission == PermissionStatus.granted) {
    download();
  } else {
    logger.logI('Single Download', 'Permission not granted, requesting...');
    ref.read(deviceStoragePermissionProvider.notifier).requestPermission(
      onDone: (isGranted) {
        if (isGranted) {
          download();
        } else {
          logger.logI('Single Download',
              'Storage permission request denied, aborting...');
        }
      },
    );
  }
}

typedef DownloadDelegate = void Function(
  Post downloadable,
);

class DownloadProviderWidget extends ConsumerWidget {
  const DownloadProviderWidget({
    super.key,
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    DownloadDelegate download,
  ) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceStoragePermissionProvider);

    return builder(
      context,
      (downloadable) => _download(
        context,
        ref,
        downloadable,
        permission: isAndroid() || isIOS() ? state.storagePermission : null,
        settings: ref.read(settingsProvider),
      ),
    );
  }
}
