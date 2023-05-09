// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/core/application/device_storage_permission/device_storage_permission_bloc.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/platform.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/utils.dart';

Future<void> _download(
  BuildContext context,
  Post downloadable, {
  PermissionStatus? permission,
  required Settings settings,
}) async {
  final service = Downloader.of(context);
  final fileNameGenerator = context.read<FileNameGenerator>();

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
    context
        .read<DeviceStoragePermissionBloc>()
        .add(DeviceStoragePermissionRequested(
      onDone: (isGranted) {
        if (isGranted) download();
      },
    ));
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
    return isAndroid() || isIOS()
        ? BlocConsumer<DeviceStoragePermissionBloc,
            DeviceStoragePermissionState>(
            listener: (context, state) {
              if (state.storagePermission ==
                      PermissionStatus.permanentlyDenied &&
                  !state.isNotificationRead) {
                showSimpleSnackBar(
                  context: context,
                  action: SnackBarAction(
                    label: 'download.open_app_settings'.tr(),
                    onPressed: openAppSettings,
                  ),
                  behavior: SnackBarBehavior.fixed,
                  content: const Text('download.storage_permission_explanation')
                      .tr(),
                );
                context.read<DeviceStoragePermissionBloc>().add(
                      const DeviceStorageNotificationDisplayStatusChanged(
                        isDisplay: true,
                      ),
                    );
              }
            },
            builder: (context, state) => builder(
              context,
              (downloadable) => _download(
                context,
                downloadable,
                permission: state.storagePermission,
                settings: ref.read(settingsProvider),
              ),
            ),
          )
        : builder(
            context,
            (downloadable) => _download(
              context,
              downloadable,
              settings: ref.read(settingsProvider),
            ),
          );
  }
}
