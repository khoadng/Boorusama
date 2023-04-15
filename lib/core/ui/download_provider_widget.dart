// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/core/application/device_storage_permission/device_storage_permission_bloc.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/settings/settings_cubit.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts.dart';

void _download(
  BuildContext context,
  Post downloadable, {
  PermissionStatus? permission,
}) {
  final service = context.read<DownloadService>();
  final fileNameGenerator = context.read<FileNameGenerator>();
  final settings = context.read<SettingsCubit>().state.settings;
  void download() => service.download(
        downloadable,
        fileNameGenerator: fileNameGenerator,
        folderName: settings.downloadPath,
      );

  // Platform doesn't require permissions, just download it right away
  if (permission == null) {
    download();

    return;
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

class DownloadProviderWidget extends StatelessWidget {
  const DownloadProviderWidget({
    super.key,
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    DownloadDelegate download,
  ) builder;

  @override
  Widget build(BuildContext context) {
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
              ),
            ),
          )
        : builder(
            context,
            (downloadable) => _download(
              context,
              downloadable,
            ),
          );
  }
}
