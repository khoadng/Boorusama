// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/permissions.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/provider.dart';

Future<void> _download(
  BuildContext context,
  WidgetRef ref,
  Post downloadable, {
  PermissionStatus? permission,
  required Settings settings,
}) async {
  final service = ref.read(downloadServiceProvider);
  final fileNameGenerator = ref.read(downloadFileNameGeneratorProvider);

  Future<void> download() async => service
      .downloadWithSettings(
        settings,
        url: downloadable.downloadUrl,
        fileNameBuilder: () => fileNameGenerator.generateFor(downloadable),
      )
      .run();

  // Platform doesn't require permissions, just download it right away
  if (permission == null) {
    download();
  }

  if (permission == PermissionStatus.granted) {
    download();
  } else {
    ref.read(deviceStoragePermissionProvider.notifier).requestPermission(
      onDone: (isGranted) {
        if (isGranted) download();
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
