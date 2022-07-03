// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/application/device_storage_permission/device_storage_permission_bloc.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:boorusama/core/core.dart';

void _download(
  BuildContext context,
  Post downloadable, {
  PermissionStatus? permission,
}) {
  // Platform doesn't require permissions, just download it right away
  if (permission == null) {
    context.read<IDownloadService>().download(downloadable);
    return;
  }

  if (permission == PermissionStatus.granted) {
    context.read<IDownloadService>().download(downloadable);
  } else {
    context
        .read<DeviceStoragePermissionBloc>()
        .add(DeviceStoragePermissionRequested());
  }
}

typedef DownloadDelegate = void Function(
  Post downloadable,
);

class DownloadProviderWidget extends StatelessWidget {
  const DownloadProviderWidget({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final Widget Function(
    BuildContext context,
    DownloadDelegate download,
  ) builder;

  @override
  Widget build(BuildContext context) {
    return isAndroid() || isIOS()
        ? BlocProvider(
            create: (context) => DeviceStoragePermissionBloc(
                initialStatus: PermissionStatus.denied)
              ..add(DeviceStoragePermissionFetched()),
            child: Builder(builder: (context) {
              return BlocConsumer<DeviceStoragePermissionBloc,
                  DeviceStoragePermissionState>(
                listener: (context, state) {
                  if (state.storagePermission ==
                          PermissionStatus.permanentlyDenied &&
                      !state.isNotificationRead) {
                    final snackBar = SnackBar(
                        action: SnackBarAction(
                            label: 'Open settings',
                            onPressed: () => openAppSettings()),
                        content: const Text(
                            'Storage permission is needed to store download files.'));

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    context.read<DeviceStoragePermissionBloc>().add(
                        const DeviceStorageNotificationDisplayStatusChanged(
                            isDisplay: true));
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
              );
            }),
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
