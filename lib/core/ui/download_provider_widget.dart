// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/permissions/permissions.dart';
import 'package:boorusama/foundation/platform.dart';

Future<void> _download(
  BuildContext context,
  WidgetRef ref,
  Post downloadable, {
  PermissionStatus? permission,
  required Settings settings,
}) async {
  final service = ref.read(downloadServiceProvider);
  final fileNameGenerator = ref.read(downloadFileNameGeneratorProvider);
  final downloadUrl = ref.read(downloadUrlProvider(downloadable));

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
